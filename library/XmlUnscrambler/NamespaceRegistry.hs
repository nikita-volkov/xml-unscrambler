module XmlUnscrambler.NamespaceRegistry
  ( NamespaceRegistry,
    new,
    lookup,
    interpretAttribute,
    interpretAttributes,
  )
where

import qualified Data.Attoparsec.Text as Attoparsec
import qualified Data.HashMap.Strict as HashMap
import qualified Data.Map.Strict as Map
import qualified Text.XML as Xml
import XmlUnscrambler.Prelude hiding (extend, insert, lookup)
import qualified XmlUnscrambler.XmlSchemaAttoparsec as XmlSchemaAttoparsec

data NamespaceRegistry
  = NamespaceRegistry
      (HashMap Text Text)
      (Maybe Text)

new :: NamespaceRegistry
new = NamespaceRegistry HashMap.empty Nothing

lookup :: Text -> NamespaceRegistry -> Maybe Text
lookup ns (NamespaceRegistry nsMap _) =
  HashMap.lookup ns nsMap

insert :: Text -> Text -> NamespaceRegistry -> NamespaceRegistry
insert alias uri (NamespaceRegistry map def) =
  NamespaceRegistry (HashMap.insert alias uri map) def

setDefault :: Text -> NamespaceRegistry -> NamespaceRegistry
setDefault =
  error "TODO"

-- |
-- Extend the registry by reading in the value if this is an \"xmlns\" attribute.
interpretAttribute :: Xml.Name -> Text -> NamespaceRegistry -> NamespaceRegistry
interpretAttribute (Xml.Name localName namespace prefix) uri =
  case namespace of
    Nothing -> case prefix of
      Nothing -> case Attoparsec.parseOnly XmlSchemaAttoparsec.qName localName of
        Right (Just "xmlns", name) -> insert name uri
        Right (Nothing, "xmlns") -> setDefault uri
        _ -> id
      _ -> id
    _ -> id

-- |
-- Extend the registry by reading in the \"xmlns\" attributes of an element.
--
-- Useful when diving into an element
interpretAttributes :: Map Xml.Name Text -> NamespaceRegistry -> NamespaceRegistry
interpretAttributes attributes x =
  Map.foldlWithKey' (\x name value -> interpretAttribute name value x) x attributes
