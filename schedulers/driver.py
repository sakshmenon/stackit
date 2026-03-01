from queueing import *

class task:
    def __init__(self, name, priority):
        self.name = name
        self.priority = priority

def display(queue):
    for task in queue:
        print(task.name, sep='\t')
        

task1 = task("task1", 1)
task2 = task("task2", 2)
task3 = task("task3", 3)
task4 = task("task4", 3)
task5 = task("task5", 2)
task6 = task("task6", 2)
task7 = task("task7", 1)
task8 = task("task8", 1)

queue = [task1, task2, task3, task4, task5, task6, task7, task8]

# priority mode
queue = priority_mode(queue)
for task in queue:
    print(task.name)

def premptive(queue, burst_time):
    time = 0
    current_task = queue.pop(0)
    while queue:
        if time < burst_time:
            time += 1
        elif time == burst_time:
            completed = input(f"Task {current_task.name} completed? (y/n)")
            if completed == "y":
                print(f"Task {current_task.name} completed")
                
            else:
                queue.append(current_task)
            current_task = queue.pop(0)
            display(queue)
            time = 0

def non_premptive(queue, burst_time):
    current_task = queue.pop(0)
    time = 0
    while queue:
        if time < burst_time:
            time += 1
        elif time == burst_time:
            completed = input(f"Task {current_task.name} completed? (y/n)")
            if completed == "y":
                print(f"Task {current_task.name} completed")
                current_task = queue.pop(0)
            else:
                pass
            time = 0

non_premptive(queue, 1000)
# premptive(queue, 1000)