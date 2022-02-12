module Models.ColumnOrder exposing (ColumnOrder(..), all, decode, encode, fromString, show, sortBy, toString)

import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Libs.List as List
import Libs.Maybe as Maybe
import Models.Project.Column as Column exposing (ColumnLike)
import Models.Project.Relation as Relation exposing (RelationLike)
import Models.Project.Table as Table exposing (TableLike)


type ColumnOrder
    = SqlOrder
    | Property
    | Name
    | Type


all : List ColumnOrder
all =
    [ Property, Name, SqlOrder, Type ]


show : ColumnOrder -> String
show order =
    case order of
        SqlOrder ->
            "By SQL order"

        Property ->
            "By property"

        Name ->
            "By name"

        Type ->
            "By type"


sortBy : ColumnOrder -> TableLike a b -> List (RelationLike c d) -> List (ColumnLike e) -> List (ColumnLike e)
sortBy order table relations columns =
    let
        tableRelations : List (RelationLike c d)
        tableRelations =
            relations |> Relation.withTableSrc table.id
    in
    case order of
        SqlOrder ->
            columns |> List.sortBy .index

        Property ->
            columns
                |> List.sortBy
                    (\c ->
                        if c.name |> Table.inPrimaryKey table |> Maybe.isJust then
                            ( 0 + sortOffset c.nullable, c.name |> String.toLower )

                        else if c.name |> Relation.inOutRelation tableRelations |> List.nonEmpty then
                            ( 1 + sortOffset c.nullable, c.name |> String.toLower )

                        else if c.name |> Table.inUniques table |> List.nonEmpty then
                            ( 2 + sortOffset c.nullable, c.name |> String.toLower )

                        else if c.name |> Table.inIndexes table |> List.nonEmpty then
                            ( 3 + sortOffset c.nullable, c.name |> String.toLower )

                        else
                            ( 4 + sortOffset c.nullable, c.name |> String.toLower )
                    )

        Name ->
            columns |> List.sortBy (\c -> c.name |> String.toLower)

        Type ->
            columns |> List.sortBy (\c -> c.kind |> String.toLower |> Column.withNullable c)


sortOffset : Bool -> Float
sortOffset b =
    if b then
        0.5

    else
        0


toString : ColumnOrder -> String
toString order =
    case order of
        SqlOrder ->
            "sql"

        Property ->
            "property"

        Name ->
            "name"

        Type ->
            "type"


fromString : String -> ColumnOrder
fromString order =
    case order of
        "sql" ->
            SqlOrder

        "property" ->
            Property

        "name" ->
            Name

        "type" ->
            Type

        _ ->
            SqlOrder


encode : ColumnOrder -> Value
encode value =
    value |> toString |> Encode.string


decode : Decode.Decoder ColumnOrder
decode =
    Decode.string |> Decode.map fromString