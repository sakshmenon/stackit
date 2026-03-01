import random

def priority_mode(queue):
    return sorted(queue, key=lambda x: x.priority)

def rev_priority_mode(queue):
    return sorted(queue, key=lambda x: x.priority, reverse=True)

def fifo_mode(queue):
    return queue

def lifo_mode(queue):
    return queue[::-1]

def shuffle_mode(queue):
    random.shuffle(queue)
    
