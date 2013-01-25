---
title: All API
---

<h1>All available APIs</h1>


#### GET /api/:version/goals/:student_id

 Get list goals

**Parameters:** 


 - student_id (required) : Student ID

 - page_size : Size for pagination

 - page_id : Page index



#### POST /api/:version/goals/:goal_id/add_grade

 Add grade for a goal

**Parameters:** 


 - goal_id (required) : Goal ID

 - due_date (required) : Due date

 - accuracy (required) : Accuracy

 - time_to_complete : Time to complete

 - note : Some more extra description



#### GET /api/:version/students

 Get list students

**Parameters:** 


 - page_size : Size for pagination

 - page_id : Page index




### GoalAPI



#### GET /api/:version/goals/:student_id

 Get list goals

**Parameters:** 


 - student_id (required) : Student ID

 - page_size : Size for pagination

 - page_id : Page index



#### POST /api/:version/goals/:goal_id/add_grade

 Add grade for a goal

**Parameters:** 


 - goal_id (required) : Goal ID

 - due_date (required) : Due date

 - accuracy (required) : Accuracy

 - time_to_complete : Time to complete

 - note : Some more extra description




### StudentAPI



#### GET /api/:version/students

 Get list students

**Parameters:** 


 - page_size : Size for pagination

 - page_id : Page index




