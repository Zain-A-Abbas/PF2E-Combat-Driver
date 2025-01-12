using Avalonia.Metadata;
using Godot;
using Newtonsoft.Json.Linq;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

public partial class EnemyDatabase : Godot.Node
{

static readonly string ENEMY_DATABASE = "res://Data/Enemies/";
static readonly string CUSTOM_ENEMIES = "user://Enemies/custom-enemies";

    public Godot.Collections.Array<Node> addEnemies() {
        Godot.Collections.Array<Node> enemiesArray = new Godot.Collections.Array<Node>();
        

        string nativePath = ProjectSettings.GlobalizePath(ENEMY_DATABASE);

        foreach (string subDirectory in Directory.GetDirectories(nativePath))
        {
            foreach (string file in Directory.GetFiles(subDirectory))
            {
                processEnemy(file, enemiesArray);
            }
        }
    

        nativePath = ProjectSettings.GlobalizePath(CUSTOM_ENEMIES);
        Directory.CreateDirectory(nativePath);
        foreach (string file in Directory.GetFiles(nativePath))
        {
            processEnemy(file, enemiesArray);
        }
        
        
        return enemiesArray;
    }

private void processEnemy(string file, Godot.Collections.Array<Node> array) {
    string json = File.ReadAllText(file);
    if (!file.Contains(".json")) {
        return;
    }
    JObject enemyData = JObject.Parse(json);

    string enemyType = (string)enemyData["type"];
    if (enemyType != "npc") {return;}
    
    string fileReference = file;
    array.Add(new EnemyFilterInfo(enemyData, fileReference));
}
public Node processSingleEnemy(string file) {
    string json = File.ReadAllText(file);
    if (!file.Contains(".json")) {
        return null;
    }
    JObject enemyData = JObject.Parse(json);

    string enemyType = (string)enemyData["type"];
    if (enemyType != "npc") {return null;}
    
    string fileReference = file;
    return(new EnemyFilterInfo(enemyData, fileReference));
}

}
