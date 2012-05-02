{-  CORSIS PortFusion    ( ]-[ayabusa 1.0.0 )
    Copyright (C) 2012 Cetin Sert             -}
#if   defined(   linux_HOST_OS )
#define __OS__ "Linux"
#elif defined( mingw32_HOST_OS )
#define __OS__ "Windows"
#elif defined( freebsd_HOST_OS )
#define __OS__ "FreeBSD"
#elif defined(  darwin_HOST_OS )
#define __OS__ "Mac OS"
#else
#define __OS__ "Generic"
#endif
#if   defined(  i386_HOST_ARCH )
#define __ARCH__ "x86"
#elif defined(x86_64_HOST_ARCH )
#define __ARCH__ "x86-64"
#elif defined(   arm_HOST_ARCH )
#define __ARCH__ "ARM"
#else
#define __ARCH__ "Unknown"
#endif


module Main where

import Prelude hiding              ((++),length,last,init)
import Control.Concurrent
import Control.Monad               (forever,void,when,unless)
import Control.Applicative
import Network.Socket hiding       (recv,send)
import Network.Socket.ByteString   (recv,sendAll)
import Data.Typeable
import Data.ByteString.Char8       (ByteString)
import qualified Data.ByteString.Char8 as B hiding (map,concatMap,filter,reverse)
import qualified Control.Exception as X
import System.Environment
import System.IO hiding  (hGetLine,hPutStr,hGetContents)
import Data.String       (IsString,fromString)
import GHC.Conc          (threadDelay)

import Foreign.Marshal.Alloc
import Foreign.Ptr
import Foreign.StablePtr
import Data.Word

import System.IO.Unsafe
import qualified Data.Vector.Storable.Mutable as SVM

import Network.Socket.Splice -- corsis library: SPLICE


-- Utility Functions

type Seconds = Int

wait :: Seconds -> IO ()
wait secs = GHC.Conc.threadDelay $ 1000000 * secs

schedule :: Seconds -> IO () -> IO ThreadId
schedule s a = forkIO $ do wait s; a

{-# INLINE (|>) #-}
(|>) :: IO () -> IO () -> IO ()
a |> b = do void $ forkIO a; b

{-# INLINE (++) #-}; (++) :: ByteString -> ByteString -> ByteString; (++) = B.append

(<:) :: Show a => Socket -> a -> IO ()
s <: a = s `sendAll` ((B.pack . show $ a) ++ "\r\n")

type ErrorIO = IO

att :: IO a -> IO (Maybe a)
att a = tryWith (const $ return Nothing) (Just <$> a)

tryRun :: IO () -> IO ()
tryRun a = tryWith (\x -> do print x; wait 1) a

{-# INLINE (=>>) #-}
infixr 0 =>>
(=>>) :: Monad m => m a -> (a -> m b) -> m a
a =>> f = do r <- a; _ <- f r; return r

{-# INLINE (//) #-}
(//) :: a -> (a -> b) -> b
x // f = f x

(???) :: [IO a] -> IO a
(???) = foldr (?>) next
  where x ?> y = x `X.catch` (\(_ :: X.SomeException) -> y)
        next   = X.throwIO $ userError "-"

newtype LiteralString = LS ByteString
instance Show     LiteralString where show (LS x) = B.unpack x
instance IsString LiteralString where fromString  = LS . B.pack


-- PortFusion Prelude

data PeerLink   = PeerLink   (Maybe SockAddr) (Maybe SockAddr) deriving Show
data FusionLink = FusionLink (Maybe SockAddr) (Maybe Port    ) (Maybe SockAddr)
  deriving Show

data PeerFault         = Loss | Impatience        deriving (Show,Typeable)
data ProtocolException = Error PeerFault PeerLink deriving (Show,Typeable)
instance X.Exception ProtocolException where

(<@>)   :: Socket ->           IO PeerLink
(<@>)   s = PeerLink <$> (att $ getSocketName s) <*> (att $ getPeerName s)

(@>-<@) :: Socket -> Socket -> IO FusionLink
a @>-<@ b =
 FusionLink <$> (att $ getPeerName a)<*>(att $ socketPort b)<*>(att $ getPeerName b)

(@<) :: Port -> IO Socket
(@<) p = do
#if !defined(IPV4ONLY)
  s <- socket AF_INET6 Stream 0 =>> opt
  setSocketOption s IPv6Only  0 // try_
  bindSocket      s $ SockAddrInet6 p 0 iN6ADDR_ANY 0
#else
  s <- socket AF_INET  Stream 0 =>> opt              -- Windows XP does not have
  setSocketOption s $ SockAddrInet  p   iNADDR_ANY   -- a dual-stack sockets API
#endif
  listen          s maxListenQueue
  print $ Listen :^: p
  return s
    where opt s = mapM_ (\o -> setSocketOption s o 1) [ ReuseAddr, KeepAlive ]

(<@) :: Socket -> IO Socket
(<@) s = do (c,_) <- accept s; configure c; print . (:.:) Accept =<< (c <@>); return c

(.@.) :: Host -> Port -> IO Socket
h .@. p = (???) . map c =<< getAddrInfo hint host port
  where hint = Just $! defaultHints { addrSocketType = Stream }
        host = Just $! B.unpack h
        port = Just $! show     p
        c a  = do s <- socket (addrFamily  a) Stream 0x6 =>> configure
                  s `connect`  addrAddress a
                  print . (:.:) Open =<< (s <@>)
                  return s

configure :: Socket -> IO ()
configure x = do
  m RecvBuffer $ fromIntegral chunk
  m SendBuffer $ fromIntegral chunk
  s KeepAlive  1
    where
      g o   = do v <- getSocketOption x o  ; {-print ("get",v);-} return v
      s o v = do      setSocketOption x o v; {-print ("set",v) -}
      m o u = do v <- g o; when (v < u) $ s o u

(#@)  :: Socket -> IO Handle
(#@)  s = socketToHandle s ReadWriteMode =>> (`hSetBuffering` NoBuffering)

(!@)  :: Socket -> IO Peer
(!@)  s = Peer s <$> (s #@)

(!<@) :: Socket -> IO Peer
(!<@) l = (!@) =<< (l <@)

(!) :: Host -> Port -> IO Peer
(!) h p = (!@) =<< h .@. p


class Disposable a where (✖) :: a -> IO () -- ✖ ✿ @

instance Disposable Socket  where
  (✖) s = do
    try_ $ do
      o <- (s <@>)
      let pc = print $ Close :.: o
      case o of
        PeerLink (Just _) (Just _) -> pc
        PeerLink (Just _) _        -> pc
        PeerLink _        (Just _) -> pc
        _                          -> return ()
    try_ $ shutdown s ShutdownBoth
    try_ $ sClose s
instance Disposable Peer    where (✖) (Peer s h) = do (s ✖); (h ✖)
instance Disposable Handle  where (✖) = try_ . hClose
instance Disposable (Ptr a) where (✖) = free
instance Disposable (StablePtr a) where (✖) = freeStablePtr


data Peer = Peer !Socket !Handle
type Host = ByteString
type Port = PortNumber

instance Read Port where
  readsPrec p s = map (\(x,y) -> (fromInteger x,y)) $ readsPrec p s

type Message = Request
data ServiceAction = Listen | Watch | Drop                                   deriving Show
data    PeerAction = Accept | Open  | Close | Receive Message | Send Message deriving Show
data  FusionAction = Establish | Terminate                                   deriving Show

data Event = ServiceAction :^: Port
           |    PeerAction :.: PeerLink
           |  FusionAction ::: FusionLink deriving Show

chunk :: ChunkSize
chunk = 8 * 1024

-- CORE

data Task =             (:>-<:)  Port
          | (Port, Host)  :-<: ((Port, Host),        Port )
          |  Port        :>-:  ((Host, Port), (Host, Port))
          |  Port        :>=:                 (Host, Port)   deriving (Show,Read)

data Request = (:-<-:)        Port
             | (:->-:)   Host Port
             | (:?)    | Run  Task                           deriving (Show,Read)

-- CORE ^

name, copyright, build :: ByteString
name      = "CORSIS PortFusion    ( ]-[ayabusa 1.0.0 )"
copyright = "(c) 2012 Cetin Sert. All rights reserved."
build     = __OS__ ++ " - " ++ __ARCH__ ++  " [" ++ __TIMESTAMP__ ++ "]"

main :: IO ()
main = withSocketsDo $ tryWith (const . print $ LS "INVALID SYNTAX") $ do
  mapM_ B.putStrLn [ b, name, copyright, "", build , b ]
  tasks <- fmap i getArgs
  mapM_ (forkIO . run) tasks
  unless (null tasks) $ do
    print (LS "zeroCopy", zeroCopy)
    void Prelude.getChar
    where
      b  = "\n"
      r  = read
      p  = B.pack
      i :: [String] -> [Task]
      i [         "]", fp,     "[" ]     = [(:>-<:) $ r fp]
      i [ lp, lh, "-", fp, fh, "[", rp ] = [(r lp, p lh) :-<: ((r fp, p fh),r rp) ]
      i [ lp, "]", fh, fp, "-", rh, rp ] = [r lp :>-: ((p fh, r fp), (p rh, r rp))]
      i [ lp, "]",         "-", rh, rp ] = [r lp :>=:                (p rh, r rp) ]
      i m = concatMap i ss
        where
          ss = map (map B.unpack . filter (not . B.null) . B.split ' ' . B.pack) m



type PortVector a = SVM.IOVector a

portVectors :: MVar (PortVector Word16, PortVector (StablePtr Socket))
portVectors = unsafePerformIO newEmptyMVar

initPortVectors :: IO ()
initPortVectors = do
  e <- isEmptyMVar portVectors
  when e $ do
    c <- SVM.new portCount =>> (`SVM.set` 0)
    s <- SVM.new portCount
    putMVar portVectors (c,s)
      where portCount = 65535

(-@<) :: Port -> IO Socket
(-@<) p = do
  let i = fromIntegral p
  withMVar portVectors $ \(c,s) -> do
    cv <- SVM.read c i
    SVM.write c i $ cv + 1
    if cv > 0 then                 SVM.read  s i >>= deRefStablePtr
              else do l <- (p @<); SVM.write s i =<< newStablePtr l; return l

(-✖) :: Port -> IO ()
(-✖) !p = do
  let i = fromIntegral p
  withMVar portVectors $ \(c,_) -> do
    cv <- SVM.read c i
    let n = cv - 1
    if  n > 0
      then SVM.write c i n
      else do
        print $ Watch :^: p
        void  . schedule 10 $ do
          withMVar portVectors $ \(c,s) -> do
            cv <- SVM.read c i
            let n = cv - 1
            SVM.write c i n
            when (n == 0) $ do
              print $ Drop :^: p
              sv <- SVM.read s i
              deRefStablePtr  sv >>= (✖); (sv ✖)

(-✖-) :: Peer -> Port -> MVar ThreadId -> IO ()
(o@(Peer s h) -✖- rp) t = do
  l <- (s <@>)
  p <- malloc :: IO (Ptr Word8)
  let n x = do (o ✖); (rp -✖); takeMVar t >>= (`throwTo` x)
  let y _ = return ()
  let f x = do free p; maybe (n x) y $ (X.fromException x :: Maybe X.AsyncException)
  tryWith f $ hGetBufSome h p 1 >>= \b -> f . X.toException $
    case b of
      0 -> Error Loss       l
      _ -> Error Impatience l

(|<>|) :: (MVar ThreadId -> IO ()) -> (MVar ThreadId -> IO ()) -> IO ()
a |<>| b = do
  ma <- newEmptyMVar
  mb <- newEmptyMVar
  ta <- forkIO $ a mb
  tb <- forkIO $ b ma
  putMVar       ma ta
  putMVar       mb tb



run :: Task -> IO ()


--- :: Task -> IO () -- serve
run ((:>-<:) fp) = do

  f <- (fp @<)

  forever $ void . forkIO . serve =<< (f !<@)

   where

    serve :: Peer -> IO ()
    serve o@(Peer s h) = do
      tryWith (const (o ✖)) $ do                         -- any exception disposes o
        q <- read . B.unpack <$> B.hGetLine h
        print . (:.:) (Receive q) =<< (s <@>)
        case q of
          (:-<-:) rp    -> o -<= rp
          (:->-:) rh rp -> o =>- rh $ rp
          (:?)          -> s <: LS build |> (o ✖)
          Run task      -> run task      |> (o ✖)

    (-<=) :: Peer -> Port -> IO ()
    o@(Peer !l _) -<= rp = do
      initPortVectors
      r <- (rp -@<)                  -- retrieve listener for port
      o -✖- rp |<>| \t -> do         -- enable patience checks
        c <- (r !<@)                 -- wait for connection
        killThread =<< takeMVar t    -- disable patience checks
        l `sendAll` "+"              -- inform other end of flow start
        o >-< c $ (rp -✖)            -- start flows & reduce listener weight on exception

    (=>-) :: Peer -> Host -> Port -> IO ()
    (o@(Peer _ _) =>- rh) rp = do
      e <- rh ! rp
      o >-< e $ return ()                                -- any exception disposes o ^


--- :: Task -> IO () - distributed reverse
run ((lp,lh) :-<: ((fp,fh),rp)) = do

  forever $ fh ! fp `X.bracketOnError` (✖) $ \f@(Peer s _) -> do

    let m = (:-<-:) rp
    print . (:.:) (Send m) =<< (s <@>)
    s <: m
    _ <- s `recv` 1

    void . forkIO $ do

      e <- lh ! lp `X.onException` (f ✖)
      f >-< e $ return ()


--- :: Task -> IO () - distributed forward
run (lp :>-: ((fh,fp),(rh,rp))) = do

  l <- (lp @<)

  forever . tryRun $ do

    c <- (l !<@)

    void . forkIO . tryWith (const (c ✖)) $ do

      f@(Peer s _) <- fh ! fp
      let m = (:->-:) rh rp
      print . (:.:) (Send m) =<< (s <@>)
      s <: m
      f >-< c $ return ()


--- :: Task -> IO () - direct forward
run (lp :>=: (rh, rp)) = do

  l <- (lp @<)

  forever $ (l !<@) `X.bracketOnError` (✖) $ \c -> do

    r <- rh ! rp
    r >-< c $ return ()


---- flow IO
(>-<) :: Peer -> Peer -> ErrorIO () -> IO ()
(a@(Peer as _) >-< b@(Peer bs _)) h = do
  !t <- as @>-<@ bs
  print $ Establish ::: t
  !m <- newMVar True
  let p = print $ Terminate ::: t
  let j = modifyMVar_ m $ \v -> do when v (do p; (a ✖); (b ✖); h); return False
  b >- a $ j
  a >- b $ j


(>-) :: Peer -> Peer -> ErrorIO () -> IO ()
(Peer as ah >- Peer bs bh) j =
  void . forkIO . tryWith (const j) $ splice chunk (as, Just ah) (bs, Just bh)
