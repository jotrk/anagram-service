import Control.Applicative ((<$>))
import Data.Char (ord)
import Network.Wai.Handler.Warp (Port)
import System.Environment
import Web.Scotty (json)
import Rest.Service
import qualified Anagram.Solver as A
import qualified Data.ByteString.Char8 as BS

defaultPort :: Port
defaultPort = foldr1 (+) $ map ord "anagram-service" -- 1525

defaultDictionary :: FilePath
defaultDictionary = "/usr/share/dict/cracklib-small"

service :: FilePath -> Port -> IO ()
service fp p = do
    dict <- map BS.unpack . BS.words <$> BS.readFile fp
    runService p "anagram" $ json . A.solver (A.buildWordSet dict) (A.buildWordGraph dict)

main :: IO ()
main = do
    args <- getArgs
    case length args of
        1 -> service defaultDictionary (readPort args)
        2 -> service (head . drop 1 $ args) (readPort args)
        _ -> service defaultDictionary defaultPort
    where
    readPort args = read (head args) :: Port
