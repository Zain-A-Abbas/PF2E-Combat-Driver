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
static readonly string CUSTOM_ENEMIES = "user://Enemies";

    public Godot.Collections.Array<Node> addEnemies() {
        Godot.Collections.Array<Node> enemiesArray = new Godot.Collections.Array<Node>();
        

        string nativePath = ProjectSettings.GlobalizePath(ENEMY_DATABASE);

        foreach (string subDirectory in Directory.GetDirectories(nativePath))
        {
            foreach (string file in Directory.GetFiles(subDirectory))
            {
                processEnemy(subDirectory, file, enemiesArray);
            }
        }
    

        nativePath = ProjectSettings.GlobalizePath(CUSTOM_ENEMIES);
        
            foreach (string subDirectory in Directory.GetDirectories(nativePath))
            {
                foreach (string file in Directory.GetFiles(subDirectory))
                {
                    processEnemy(subDirectory, file, enemiesArray);
                }
            }
        
        
        return enemiesArray;
    }

private void processEnemy(string subDirectory, string file, Godot.Collections.Array<Node> array) {
    string enemyFileDirectory = Path.Combine(subDirectory, file);
    string json = File.ReadAllText(enemyFileDirectory);
    JObject enemyData = JObject.Parse(json);

    string enemyType = (string)enemyData["type"];
    if (enemyType != "npc") {return;}
    
    string fileReference = enemyFileDirectory;
    array.Add(new EnemyFilterInfo(enemyData, fileReference));
}

}
