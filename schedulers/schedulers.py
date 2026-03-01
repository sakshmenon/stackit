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
            time = 0