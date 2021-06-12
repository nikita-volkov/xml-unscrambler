module XmlUnscrambler
  ( -- * Execution
    parseByteString,
    parseFile,

    -- * Parsers by context

    -- ** Element
    AstParser.Element,
    AstParser.elementName,
    AstParser.elementNameIs,
    AstParser.children,
    AstParser.childrenByName,
    AstParser.attributesByName,

    -- ** Nodes
    AstParser.Nodes,
    AstParser.elementNode,
    AstParser.textNodeAsIs,
    AstParser.textNodeParsed,

    -- ** ByName
    AstParser.ByName,
    AstParser.byName,
  )
where

import qualified Data.ByteString.Lazy as LazyByteString
import qualified Data.Text as Text
import qualified Text.XML as XmlConduit
import qualified Text.XML.Unresolved as XmlConduit (InvalidEventStream (..))
import qualified XmlUnscrambler.AstParser as AstParser
import XmlUnscrambler.Prelude
import qualified XmlUnscrambler.XmlConduitWrapper as XmlConduitWrapper

-- |
-- Parse XML bytestring.
parseByteString :: AstParser.Element a -> ByteString -> Either Text a
parseByteString astParser input =
  XmlConduitWrapper.parseByteString input >>= parseXmlConduitDocument astParser

-- |
-- Parse XML file.
parseFile :: AstParser.Element a -> FilePath -> IO (Either Text a)
parseFile astParser path =
  fmap (>>= parseXmlConduitDocument astParser) $
    XmlConduitWrapper.parseFile path

parseXmlConduitDocument :: AstParser.Element a -> XmlConduit.Document -> Either Text a
parseXmlConduitDocument astParser =
  first renderError . AstParser.parseElement astParser . XmlConduit.documentRoot
  where
    renderError :: AstParser.Error -> Text
    renderError =
      error "TODO"
