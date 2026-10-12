return {
    id = "SkipSpaceTravel",
    name = "Skip Space Travel",
    version = "1.0.1",
    description = "Skip repeated mission space-travel scenes without bypassing loading.",
    settings = {
        {key = "enabled", type = "bool", name = "Skip Space Travel", default = true,
         desc = "Skip the repeated Den/planet departure, hyperspace intro, and approach scenes. Hyperspace still lasts as long as loading takes. Changes apply to subsequent travel scenes."},
    },
}
