using Godot;
using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
using System.Linq;

public partial class EnemyFilterInfo : Node
{
    public string fileReference;

    public string enemyName;

    int level;
    int hp;
    int ac;

    Godot.Collections.Dictionary abilityScores;
    Godot.Collections.Dictionary savingThrows;

    int perception;

    Godot.Collections.Dictionary speed;

    Godot.Collections.Array<string> immunities;
    Godot.Collections.Dictionary resistances;
    Godot.Collections.Dictionary weaknesses;

    string alignment;
    string rarity;
    string size;

    Godot.Collections.Array<string> traits;

    public EnemyFilterInfo(JObject enemyData, string fileLocation)
    {
        fileReference = fileLocation;

        // Adds the system for easier data retrieval here
        JObject enemySystemData = (JObject)enemyData["system"]["attributes"];
        JObject enemyTraits = (JObject)enemyData["system"]["traits"];
        JObject enemySpeed = (JObject)enemySystemData["speed"];


        enemyName = (string)enemyData["name"];
        level = (int)enemyData["system"]["details"]["level"]["value"];
        hp = (int)enemySystemData["hp"]["max"];
        ac = (int)enemySystemData["ac"]["value"];

        JObject jObjectAbilityScores = new JObject();
        jObjectAbilityScores["str"] = enemyData["system"]["abilities"]["str"]["mod"];
        jObjectAbilityScores["dex"] = enemyData["system"]["abilities"]["dex"]["mod"];
        jObjectAbilityScores["con"] = enemyData["system"]["abilities"]["con"]["mod"];
        jObjectAbilityScores["int"] = enemyData["system"]["abilities"]["int"]["mod"];
        jObjectAbilityScores["wis"] = enemyData["system"]["abilities"]["wis"]["mod"];
        jObjectAbilityScores["cha"] = enemyData["system"]["abilities"]["cha"]["mod"];
        abilityScores = JObjectToDictionary(jObjectAbilityScores);

        JObject jObjectSavingThrows = new JObject
        {
            ["fortitude"] = enemyData["system"]["saves"]["fortitude"]["value"],
            ["reflex"] = enemyData["system"]["saves"]["reflex"]["value"],
            ["will"] = enemyData["system"]["saves"]["will"]["value"]
        };
        savingThrows = JObjectToDictionary(jObjectSavingThrows);

        perception = (int)enemyData["system"]["attributes"]["perception"]["value"];

        JObject jObjectSpeed = new JObject
        {
            ["land"] = enemySystemData["speed"]["value"]
        };
        // Adds every type of speed that is not land speed
        if (enemySpeed.ContainsKey("otherSpeeds"))
        {
            JArray otherSpeedsArray = (JArray)enemySpeed["otherSpeeds"];
            foreach (var speedType in otherSpeedsArray)
            {
                // Type of speed (fly swim etc.)
                string speedCategory = (string)speedType["type"];
                // How many feet per action
                int speedFeet = (int)speedType["value"];
                jObjectSpeed[speedCategory] = speedFeet;
            }
        }
        speed = JObjectToDictionary(jObjectSpeed);
        // Adds any immunities, weaknesses, and resistances the creature has
        // Immunities are only a binary, so stored in an array
        if (enemySystemData.ContainsKey("immunities"))
        {
            foreach (var immunity in enemySystemData["immunities"])
            {
                //immunities.Add(immunity["type"].ToString());
            }
        }

        JObject jObjectWeaknesses = new JObject();
        if (enemySystemData.ContainsKey("weaknesses")) {
            JArray weaknessesArray = (JArray)enemySystemData["weaknesses"];
            foreach (var weakness in weaknessesArray)
            {
                string weaknessType = (string)weakness["type"];
                int weaknessValue = (int)weakness["value"];
                jObjectWeaknesses[weaknessType] = weaknessValue;
            }
        }
        weaknesses = JObjectToDictionary(jObjectWeaknesses);

        JObject jObjectResistances = new JObject();
        if (enemySystemData.ContainsKey("resistances")) {
            JArray resistancesArray = (JArray)enemySystemData["resistances"];
            foreach (var resistance in resistancesArray)
            {
                string resistanceType = (string)resistance["type"];
                int resistanceValue = (int)resistance["value"];
                jObjectResistances[resistanceType] = resistanceValue;
            }
        }
        resistances = JObjectToDictionary(jObjectResistances);


        alignment = (string)enemyData["system"]["details"]["alignment"]["value"];
        rarity = (string)enemyTraits["rarity"];
        size = (string)enemyTraits["size"]["value"];
        traits = new Godot.Collections.Array<string>();
        foreach (string enemyTrait in enemyTraits["value"])
        {
            traits.Add(enemyTrait);
        }

    }
    public Godot.Collections.Dictionary JObjectToDictionary(JObject jObject)
    {
        Godot.Collections.Dictionary dictionary = new Godot.Collections.Dictionary();

        foreach (var property in jObject)
        {
            string key = property.Key;
            JToken value = property.Value;

            if (value.Type == JTokenType.Object)
            {
                // Recursion
                dictionary[key] = JObjectToDictionary((JObject)value);
            }
            else if (value.Type == JTokenType.Array)
            {
                var godotArray = new Godot.Collections.Array();
                foreach (var item in (JArray)value)
                {
                    godotArray.Add(item.ToString());
                }
                dictionary[key] = godotArray;
            }
            else if (value.Type == JTokenType.Integer)
            {
                dictionary[key] = (int)value;
            }
            else
            {
                dictionary[key] = value.ToString();
            }
        }

        return dictionary;
    }
}
