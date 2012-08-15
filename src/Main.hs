-- CORSIS PortFusion ]-[ayabusa
-- Copyright © 2012  Cetin Sert

{-# LANGUAGE ScopedTypeVariables, CPP, BangPatterns, TypeSynonymInstances, TypeOperators,
             OverloadedStrings, DeriveDataTypeable, PostfixOperators, TupleSections       #-}

#if !defined(__OS__)
#define __OS__   "interactive"
#endif
#if !defined(__ARCH__)
#define __ARCH__ "interactive"
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
import qualified Data.ByteString.Char8 as B hiding (map,concatMap,reverse)
import qualified Control.Exception as X
import System.Environment
import System.Timeout
import System.IO hiding  (hGetLine,hPutStr,hGetContents)
import Data.String       (IsString,fromString)
import Data.List         (elemIndices,(++),find)

import Foreign.Storable
import Foreign.Marshal.Array
import Foreign.Marshal.Alloc
import Foreign.Ptr
import Foreign.StablePtr
import Data.Word
import Data.Char

import System.IO.Unsafe

import Network.Socket.Splice -- corsis library: SPLICE
import GHC.Conc (numCapabilities)

---------------------------------------------------------------------------------------------UTILITY

type Seconds = Int
secs     :: Int -> Seconds;                  secs         = (* 1000000)
wait     :: Seconds -> IO ();                wait         = threadDelay . secs
schedule :: Seconds -> IO () -> IO ThreadId; schedule s a = forkIO $! wait s >> a

{-# INLINE (<>)  #-}; (<>) :: ByteString -> ByteString -> ByteString; (<>)   = B.append
{-# INLINE (//)  #-}; (//) :: a -> (a -> b) -> b;                     x // f = f x
{-# INLINE (|>)  #-}; (|>) :: IO () -> IO () -> IO ();                a |> b = forkIO a >> b
{-# INLINE (=>>) #-}; infixr 0 =>>; (=>>) :: Monad m => m a -> (a -> m b) -> m a
a =>> f = do r <- a; _ <- f r; return r

type ErrorIO = IO
att    :: IO a  -> IO (Maybe a);       att    a = tryWith (const $! return Nothing) (Just <$> a)
tryRun :: IO () -> IO ();              tryRun a = tryWith (\x -> do print x; wait 2) a
(???)  :: ErrorIO a -> [IO a] -> IO a; e ??? as = foldr (?>) e as
  where x ?> y = x `X.catch` (\(_ :: X.SomeException) -> y)

newtype LiteralString = LS ByteString
instance IsString LiteralString where fromString  = LS . B.pack
instance Show     LiteralString where show (LS x) = B.unpack x
instance Read     LiteralString where readsPrec p s = map (\(s,r) -> (LS s,r)) $! readsPrec p s

-----------------------------------------------------------------------------------------------PEERS

data PeerLink   = PeerLink   (Maybe SockAddr) (Maybe SockAddr)                  deriving Show
data FusionLink = FusionLink (Maybe SockAddr) (Maybe Port    ) (Maybe SockAddr) deriving Show
data ProtocolException = Loss PeerLink | Silence [SockAddr]           deriving (Typeable,Show)
instance X.Exception ProtocolException where

(<:) :: Show a => Socket -> a -> IO (); s <: a = s `sendAll` ((B.pack . show $! a) <> "\r\n")

(<@>)   :: Socket ->           IO PeerLink
(<@>)   s = PeerLink <$> (att $! getSocketName s)<*>(att $! getPeerName s)

(@>-<@) :: Socket -> Socket -> IO FusionLink
a @>-<@ b = FusionLink <$> (att $! getPeerName a)<*>(att $! socketPort  b)<*>(att $! getPeerName b)

(@<) :: AddrPort -> IO Socket
(@<) ap = do
  (f,a) <- (ap ?:)
  s <- socket f Stream 0x6 =>> \s -> mapM_ (\o -> setSocketOption s o 1) [ ReuseAddr, KeepAlive ]
  bindSocket s a; listen s maxListenQueue
  print $! Listen :^: (faf f, ap)
  return s

(<@) :: Socket -> IO Socket
(<@) s = do (c,_) <- accept s; configure c; print . (:.:) Accept =<< (c <@>); return c

(.@.) :: Host -> Port -> IO Socket
h .@. p = getAddrInfo hint host port >>= \as -> e as ??? map c as
  where hint = Just $! defaultHints { addrSocketType = Stream }
        host = Just $! B.unpack h
        port = Just $! show     p
        e as = X.throwIO . Silence $! map addrAddress as
        c a  = do s <-      socket (addrFamily  a) Stream 0x6 =>> configure
                  r <- s `connect`  addrAddress a // timeout (secs 3)
                  case r of
                    Nothing -> do (s ✖); X.throw $! Silence [addrAddress a]
                    Just _  -> do print . (:.:) Open =<< (s <@>);  return s

configure :: Socket -> IO ()
configure s = m RecvBuffer c >> m SendBuffer c >> setSocketOption s KeepAlive 1
   where m o u = do v <- getSocketOption s o; when (v < u) $! setSocketOption s o u
         c     = fromIntegral chunk

chunk :: ChunkSize
chunk = 8 * 1024

data Peer = Peer !Socket !Handle

(!@)  :: Socket ->         IO Peer;   (!@)  s = Peer s <$> (s #@)
(!<@) :: Socket ->         IO Peer;   (!<@) l = (!@)   =<< (l <@)
(!)   :: Host   -> Port -> IO Peer;   (!) h p = (!@)   =<< h .@. p
(#@)  :: Socket ->         IO Handle
(#@)  s = socketToHandle s ReadWriteMode =>> (`hSetBuffering` NoBuffering)

class    Disposable a       where (✖) :: a -> IO ()
instance Disposable Socket  where
  (✖) s = do
    try_ $! print . (Close :.:) =<< (s <@>)
    try_ $! shutdown s ShutdownBoth
    try_ $! sClose   s
instance Disposable Peer          where (✖) (Peer s h) = do (s ✖); (h ✖)
instance Disposable Handle        where (✖) = try_ . hClose
instance Disposable (Ptr       a) where (✖) = free
instance Disposable (StablePtr a) where (✖) = freeStablePtr

----------------------------------------------------------------------------------------------------

type Host = ByteString
type Port = PortNumber

instance Read Port where readsPrec p s = map (\(i,r) -> (fromInteger i,r)) $! readsPrec p s

data AddrPort = !Host :@: !Port
instance Show AddrPort where
  show (a:@:p) = if B.null     a then show p else f a ++ ":" ++ show p
    where f  a = if B.elem ':' a then "["++show (LS a)++"]" else show (LS a)
instance Read AddrPort where
  readsPrec p s =
    case reverse $! elemIndices ':' s of { [] -> all s; (0:_) -> all $! drop 1 s; (i:_) -> one i s }
    where all   s = readsPrec p s >>= \(p, s') -> return $! ("" :@: p, s')
          one i s = do
            let (x,y) = splitAt i s // \(a,b) -> (dropWhile isSpace a, b)
            (a,_) <- readsPrec p $! "\"" ++ filter (\c -> c /= '[' && ']' /= c) x ++ "\""
            (p,r) <- readsPrec p $! tail y
            return $! (a :@: p, r)

faf :: Family -> LiteralString
faf x = LS $! case x of { AF_INET6 -> sf; AF_UNSPEC -> sf; AF_INET -> "IPv4"; _-> B.pack $! show x }
  where sf = "IPv6(+4?)"

(?:) :: AddrPort -> IO (Family, SockAddr)
(?:) (a :@: p)= f . c <$> getAddrInfo (Just hints) n (Just $! show p)
  where hints = defaultHints { addrFlags = [ AI_PASSIVE, AI_NUMERICHOST ], addrSocketType = Stream }
        n     = if B.null a then Nothing else Just $! B.unpack a
        c  xs = case find ((== AF_INET6) . addrFamily) xs of Just v6 -> v6; Nothing -> head xs
        f  x  = (addrFamily x, addrAddress x)

----------------------------------------------------------------------------------------------EVENTS

type Message = Request
data ServiceAction = Listen | Watch | Drop                                   deriving Show
data    PeerAction = Accept | Open  | Close | Receive Message | Send Message deriving Show
data  FusionAction = Establish | Terminate                                   deriving Show

data Event = ServiceAction :^: (LiteralString, AddrPort)
           |    PeerAction :.: PeerLink
           |  FusionAction ::: FusionLink deriving Show

------------------------------------------------------------------------------------------------WIRE

data Task =             (:><:)  AddrPort
          | (Port, Host) :-<: ((Port, Host),    AddrPort )
          |  AddrPort    :>-: ((Host, Port), (Host, Port))
          |  AddrPort    :>=:                (Host, Port)   deriving (Show,Read)

data Request = (:-<-:)    AddrPort
             | (:->-:)   Host Port
             | (:?)    | Run  Task                          deriving (Show,Read)

------------------------------------------------------------------------------------------------MAIN

name, copyright, build :: ByteString
name      = "CORSIS PortFusion    ( ]-[ayabusa 1.2.1 )"
copyright = "(c) 2012 Cetin Sert. All rights reserved."
build     = __OS__ <> " - " <> __ARCH__ <>  " [" <> __TIMESTAMP__ <> "]"

main :: IO ()
main = withSocketsDo $! tryWith (const . print $! LS "INVALID SYNTAX") $! do
  mapM_ B.putStrLn [ "\n", name, copyright, "", build, "\n" ]
  tasks <- parse <$> getArgs
  when   (null tasks) $! mapM_ B.putStrLn [ "  Documentation: http://fusion.corsis.eu", "",""]
  unless (null tasks) $! do
    when zeroCopy              $! print (LS "zeroCopy"       , zeroCopy       )
    when (numCapabilities > 1) $! print (LS "numCapabilities", numCapabilities)
    mapM_ (forkIO . run) tasks
    void Prelude.getChar


parse :: [String] -> [Task]
parse [         "]", ap, "["         ] = [(:><:) $! read ap                                        ]
parse [ lp, lh, "-", fp, fh, "[", ap ] = [(read lp, B.pack lh) :-<: ((read fp, B.pack fh),read ap) ]
parse [ ap, "]", fh, fp, "-", rh, rp ] = [read ap :>-: ((B.pack fh, read fp), (B.pack rh, read rp))]
parse [ ap, "]",         "-", rh, rp ] = [read ap :>=:                        (B.pack rh, read rp) ]
parse m = concatMap parse $! map (map B.unpack . filter (not . B.null) . B.split ' ' . B.pack) m

-----------------------------------------------------------------------------------------PORTVECTORS

type PortVector a = Ptr a

portVectors            :: MVar (PortVector Word16, PortVector (StablePtr Socket))
portVectorsInitialized :: MVar Bool
initPortVectors        :: IO   ()

portVectors            = unsafePerformIO $! newEmptyMVar
portVectorsInitialized = unsafePerformIO $! newMVar False
initPortVectors        = modifyMVar_ portVectorsInitialized $! \initialized ->
  when (not initialized) initialize >> return True
  where initialize = putMVar portVectors =<< (,) <$> mallocArray0 pc <*> mallocArray pc
        pc         = 65536

        
(-@<) :: AddrPort -> IO Socket
(-@<) ap@(_ :@: p) = do
  let i = fromIntegral p
  withMVar portVectors $! \(c,s) -> do
    cv <- peekElemOff c i
    if cv>0 then do pokeElemOff c i $! cv+1; peekElemOff s i >>= deRefStablePtr
            else do l <-(ap @<);pokeElemOff s i =<< newStablePtr l;pokeElemOff c i $! cv+1; return l

(-✖) :: AddrPort -> IO ()
(-✖) ap@(_ :@: p) = do
  let i = fromIntegral p
  withMVar portVectors $! \(c,_) -> do
    cv <- peekElemOff c i
    let n = cv-1
    if  n > 0
      then pokeElemOff c i n
      else do
        print $! Watch :^: (faf AF_UNSPEC, ap)
        void  . schedule 10 $! do
          withMVar portVectors $! \(c,s) -> do
            cv <- peekElemOff c i
            let n = cv-1
            pokeElemOff c i n
            when (n == 0) $! do
              print $! Drop :^: (faf AF_UNSPEC, ap)
              sv <- peekElemOff s i
              deRefStablePtr sv >>= (✖); (sv ✖)

-----------------------------------------------------------------------------------------------CHECK

(|<>|) :: (MVar ThreadId -> IO ()) -> (MVar ThreadId -> IO ()) -> IO ()
a |<>| b = do
  ma <- newEmptyMVar  ; mb <- newEmptyMVar
  ta <- forkIO $! a mb; tb <- forkIO $! b ma
  putMVar        ma ta; putMVar        mb tb

(-✖-) :: Peer -> AddrPort -> MVar ThreadId -> IO ()
(o@(Peer s _) -✖- rp) t = do
  l <- (s <@>)
  let n x = do (o ✖); (rp -✖); takeMVar t >>= (`throwTo` x)
  let f x = do maybe (n x) (const $! return ()) $! (X.fromException x :: Maybe X.AsyncException)
  tryWith f $! do _ <- recv s 0; f . X.toException $! Loss l

-----------------------------------------------------------------------------------------------TASKS

run :: Task -> IO () -- serve
run ((:><:) fp) = do

  f <- (fp @<)

  forever $! void . forkIO . serve =<< (f !<@)

   where

    serve :: Peer -> IO ()
    serve o@(Peer s h) = do
      tryWith (const (o ✖)) $! do                        -- any exception disposes o
        q <- read . B.unpack <$> B.hGetLine h
        print . (:.:) (Receive q) =<< (s <@>)
        case q of
          (:-<-:)    rp -> o -<-       rp
          (:->-:) rh rp -> o ->- rh $! rp
          (:?)          -> s <: LS build |> (o ✖)
          Run task      -> run task      |> (o ✖)

    (-<-) :: Peer -> AddrPort -> IO ()
    o@(Peer !l _) -<- rp = do
      initPortVectors
      r <- (rp -@<)
      o -✖- rp |<>| \t -> do
        let f = killThread =<< takeMVar t
        tryWith (const f) $! do
          c <- (r !<@); f
          l `sendAll` "+"
          o >-< c $! (rp -✖)

    (->-) :: Peer -> Host -> Port -> IO ()
    (o ->- rh) rp = do
      e <- rh ! rp
      o >-< e $! return ()                               -- any exception disposes o ^


--- :: Task -> IO () - distributed reverse
run ((lp,lh) :-<: ((fp,fh),rp)) = do

  forever . tryRun $! fh ! fp `X.bracketOnError` (✖) $! \f@(Peer s _) -> do

    let m = (:-<-:) rp
    print . (:.:) (Send m) =<< (s <@>)
    s <: m
    _ <- s `recv` 1

    void . forkIO $! do

      e <- lh ! lp `X.onException` (f ✖)
      f >-< e $! return ()


--- :: Task -> IO () - distributed forward
run (lp :>-: ((fh,fp),(rh,rp))) = do

  l <- (lp @<)

  forever . tryRun $! do

    c <- (l !<@)

    void . forkIO . tryWith (const (c ✖)) $! do

      f@(Peer s _) <- fh ! fp
      let m = (:->-:) rh rp
      print . (:.:) (Send m) =<< (s <@>)
      s <: m
      f >-< c $! return ()


--- :: Task -> IO () - direct forward
run (lp :>=: (rh, rp)) = do

  l <- (lp @<)

  forever . tryRun $! (l !<@) `X.bracketOnError` (✖) $! \c -> do

    r <- rh ! rp
    r >-< c $! return ()

----------------------------------------------------------------------------------------------SPLICE

(>-<) :: Peer -> Peer -> ErrorIO () -> IO ()
(a@(Peer as _) >-< b@(Peer bs _)) h = do
  !t <- as @>-<@ bs
  print $! Establish ::: t
  !m <- newMVar True
  let p = print $! Terminate ::: t
  let j = modifyMVar_ m $! \v -> do when v (do p; (a ✖); (b ✖); h); return False
  a >- b $! j; b >- a $! j

(>-) :: Peer -> Peer -> ErrorIO () -> IO ()
(Peer as ah >- Peer bs bh) j =
  void . forkIO . tryWith (const j) $! splice chunk (as, Just ah) (bs, Just bh)