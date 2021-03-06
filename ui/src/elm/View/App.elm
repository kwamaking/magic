module View.App exposing (view)

import Color exposing (Color)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import State.Model exposing (Model)
import String
import Types.Light as Light exposing (Light)
import Utils.Tuple exposing ((=>))


view : Model -> Html msg
view { lights } =
    div [ class "app" ]
        [ lights
            |> Dict.toList
            |> List.map light
            |> List.concat
            |> List.append [ div [ class "background" ] [] ]
            |> div [ class "scene" ]
        ]


light : ( String, Light ) -> List (Html msg)
light ( id, { status, position, color } ) =
    let
        lightElement attributes =
            div <|
                [ title id
                , style
                    [ "top" => toString position.y ++ "px"
                    , "left" => toString position.x ++ "px"
                    ]
                ]
                    ++ attributes

        overlay attributes =
            lightElement <| [ class "overlay" ] ++ attributes
    in
    case status of
        Light.Enabled ->
            let
                { red, blue, green, alpha } =
                    Color.toRgb <|
                        if status /= Light.Enabled then
                            Color.rgba 255 255 255 0.3
                        else
                            color

                colorCss =
                    [ toFloat red
                    , toFloat green
                    , toFloat blue
                    , alpha
                    ]
                        |> List.map toString
                        |> List.intersperse ", "
                        |> String.concat
                        |> (\values -> "rgba(" ++ values ++ ")")

                background =
                    style [ "background" => colorCss ]
            in
            [ lightElement [ class "bulb", background ] []
            , lightElement [ class "glow", glow colorCss ] []
            , overlay [] []
            ]

        Light.Disabled ->
            [ overlay [ class "disabled" ] [] ]


glow : String -> Html.Attribute msg
glow colorCss =
    let
        shadowRadius =
            170

        spreadAmount =
            0.3

        shadowPositioning =
            "0 0 "
                ++ toString shadowRadius
                ++ "px "
                ++ toString (shadowRadius * spreadAmount)
                ++ "px"
    in
    style [ "box-shadow" => shadowPositioning ++ " " ++ colorCss ]
