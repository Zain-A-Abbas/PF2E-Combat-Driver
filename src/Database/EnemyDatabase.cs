using Godot;
using Newtonsoft.Json.Linq;
using System.IO;

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
                string enemyFileDirectory = Path.Combine(subDirectory, file);
                string json = File.ReadAllText(enemyFileDirectory);
                JObject enemyData = JObject.Parse(json);

                string enemyType = (string)enemyData["type"];
                if (enemyType != "npc") {continue;}
                
                string fileReference = enemyFileDirectory;
                enemiesArray.Add(new EnemyFilterInfo(enemyData, fileReference));
            }
        }

        nativePath = ProjectSettings.GlobalizePath(CUSTOM_ENEMIES);
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
