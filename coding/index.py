
import re
import requests as req
import json as js
import random
from asyncio import run, create_task, sleep
from multiprocessing import Process
import threading


def reverse_list(l):
    return l[::-1]

def unique_elements(l):
    res = set()
    for i in l:
        res.add(i)
    return res

def text_analysis(s):
    new_s = []
    splitted_s = s.split()
    for i in splitted_s:
        tmp = {
            "word": i,
            "count": len(i)
        }
        new_s.append(tmp)
    return new_s

def process_log_file(file_name):
    list = []
    pattern = re.compile(r'(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})') 

    with open(file=file_name, mode="r") as f:
        content = f.readlines()
        # s_content = content.split()
        for i in content:
            r = pattern.search(i)[0]
            if r is not None:
                
                print(r)
                list.append(r)
    return list

def genIp():
    return  f"{str(random.randint(1, 255))}.{str(random.randint(1, 255))}.{str(random.randint(1, 255))}.{str(random.randint(1, 255))}"

async def loadData(url):
    try:
        response = req.get(url)
        if response.status_code == 200:
            data = response.json()
            return data
    except Exception:
        print('err => ', Exception)

async def py_project():
    todos = await loadData('https://jsonplaceholder.typicode.com/todos')
    users = await loadData('https://jsonplaceholder.typicode.com/users')


    new_users = []
    for todo in todos:
        id = todo['id']
        tmp = []
        if id in users[0]['id']:
            tmp.append(todo)
        new_users.append()

        

    with open(file='./files/users.json', mode="w") as w:
        js.dump(new_users, w, indent=4)

    
    list = []
    with open(file='./files/users.json', mode="r") as r:
        content = js.loads(r.read())
        
        for i in content:
            data = {
                'id': i.get('id'),
                'name': i.get('name'),
                'email': i.get('email'),
                'username': i['username'],
                'ip': genIp()
            }
            list.append(data)

    with open(file='./files/users.json', mode="w") as wf:
        wf.write(str(list))

    return list


import asyncio

async def print_numbers():
   for i in range(10):
       print(f"{i}")
       await asyncio.sleep(1)

async def print_letters():
   for letter in 'abcdefghij':
       print(f"{letter}")
       await asyncio.sleep(1)

async def main():
   task1 = await asyncio.create_task(print_numbers())
   task2 = await asyncio.create_task(print_letters())
#    await task1
#    await task2

asyncio.run(main())



def print_numbers():
    for i in range(10):
        print(f"{i}")

def print_letters():
    for letter in 'abcdefghij':
        print(f"{letter}")

# processing 
p1 = Process(target=print_numbers)
p2 = Process(target=print_letters)

p1.start()
p2.start()

p1.join()
p2.join()

# threading
t1 = threading.Thread(target=print_numbers)
t2 = threading.Thread(target=print_letters)

t1.start()
t2.start()

t1.join()
t2.join()


class User:
  def __init__(self, name, age, email):
    self.name = name
    self.age = age
    self.email = email

  def toString(self):
      str = self.name + self.age + self.email
      print(str)
p1 = User("John", 36, "sam@mail.com")

print(p1.name)
print(p1.age)
print(p1.email)
print(p1.toString())

# inheritence, polymorphism, ...

# l = [1,2,3,4,5,6, 6, 5, 2]
# print(reverse_list(l))

# print(unique_elements(l))

# s = "hello world !"
# print(text_analysis(s))

# print(process_log_file("access.log"))

print(run(py_project()))

