module Utils where

-- 🙈
fromJust :: Maybe a -> a
fromJust (Just a) = a

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

kcodensity :: Monad m => m a -> (forall r. K (m r) (m r) a)
kcodensity = (>>=)

kuncodensity :: Monad m => (forall r. K (m r) (m r) a) -> m a
kuncodensity k = k pure
