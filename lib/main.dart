import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(HabitTrackerApp());
}

class HabitTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HabitSlider',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HabitListScreen(),
    );
  }
}

class Habit {
  String name;
  double progress;

  Habit({required this.name, this.progress = 0.0});
}

class HabitListScreen extends StatefulWidget {
  @override
  _HabitListScreenState createState() => _HabitListScreenState();
}

class _HabitListScreenState extends State<HabitListScreen> {
  List<Habit> habits = [];
  TextEditingController habitController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  _loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedHabits = prefs.getStringList('habits');
    if (savedHabits != null) {
      setState(() {
        habits = savedHabits
            .map((habitString) => Habit(
                  name: habitString,
                  progress: 0.0, //progresso inicial deve ser 0
                ))
            .toList();
      });
    }
  }

  _saveHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> habitNames = habits.map((habit) => habit.name).toList();
    prefs.setStringList('habits', habitNames);
  }

  void _addHabit() {
    if (habitController.text.isEmpty) return;

    setState(() {
      habits.add(Habit(name: habitController.text));
    });
    _saveHabits();
    habitController.clear();
  }

  void _updateProgress(int index, double value) {
    setState(() {
      habits[index].progress = value;
    });
    _saveHabits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HabitSlider'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: habitController,
              decoration: InputDecoration(
                labelText: 'Digite seu próximo hábito',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addHabit,
              child: Text('Adcionar Hábito'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(habits[index].name),
                    subtitle: Text(
                        'Progresso: ${(habits[index].progress * 100).toStringAsFixed(0)}%'),
                    trailing: SizedBox(
                      width: 150,
                      child: Slider(
                        value: habits[index].progress,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: '${(habits[index].progress * 100).toStringAsFixed(0)}%',
                        onChanged: (double value) {
                          _updateProgress(index, value);
                        },
                      ),
                    ),
                    //se progresso = 100, concluir
                    leading: habits[index].progress == 1.0
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}