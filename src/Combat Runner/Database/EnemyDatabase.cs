using Godot;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Text.Json.Serialization;

public partial class EnemyDatabase : Node
{

static readonly string ENEMY_DATABASE = "res://Data/Enemies/";

    public Godot.Collections.Array<Node> addEnemies() {
        string nativePath = ProjectSettings.GlobalizePath(ENEMY_DATABASE);

        DirAccess directory = DirAccess.Open(ENEMY_DATABASE);
        Godot.Collections.Array<Node> enemiesArray = new Godot.Collections.Array<Node>();

        foreach (string subDirectory in Directory.GetDirectories(nativePath))
        {
            foreach (string file in Directory.GetFiles(subDirectory))
            {
                string enemyFileDirectory = Path.Combine(subDirectory, file);
                string json = File.ReadAllText(enemyFileDirectory);
                JObject enemyData = JObject.Parse(json);

                string enemyType = (string)enemyData["type"];
                if (enemyType != "npc") {continue;}
                
                string fileReference = enemyFileDirectory;
                enemiesArray.Add(new EnemyFilterInfo(enemyData, fileReference));
            }
        }

        
        return enemiesArray;
    }

}
