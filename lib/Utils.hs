module Utils where

-- 🙈
import Control.Monad.IO.Class

-- Either
etpure :: Applicative m => a -> m (Either e a)
etpure = pure . pure

etbind :: Monad m => m (Either e a) -> (a -> m (Either e b)) -> m (Either e b)
etbind ma amb = ma >>= either (pure . Left) amb

etlift :: Functor m => m a -> m (Either e a)
etlift = fmap pure

-- Continuations
type K i o a = (a -> i) -> o

kmap :: (a -> b) -> K i o a -> K i o b
kmap f k cb = k $ cb . f

kpure :: a -> K x x a
kpure = flip ($)

kjoin :: K x o (K i x a) -> K i o a
kjoin k cb = k ($ cb)

kbind :: K x o a -> (a -> K i x b) -> K i o b
kbind = flip $ \f -> kjoin . kmap f

type EK i o e a = K i o (Either e a)

ekmap :: (a -> b) -> EK i o e a -> EK i o e b
ekmap = kmap . fmap

ekpure :: a -> EK x x e a
ekpure = kpure . pure

ekbind :: EK r r e a -> (a -> EK r r e b) -> EK r r e b
ekbind k f cb = k $ either (cb . Left) (($ cb) . f)

eklift :: K i o a -> EK i o e a
eklift = kmap Right

kcodensity :: forall r m a. Monad m => m a -> (a -> m r) -> m r
kcodensity = (>>=)

kuncodensity :: forall r m a. Monad m => ((r -> m r) -> m a) -> m a
kuncodensity = ($ pure)

kliftIO :: forall r s m a. MonadIO m => ((r -> IO r) -> IO a) -> (a -> m s) -> m s
kliftIO k = kcodensity $ liftIO $ kuncodensity k
