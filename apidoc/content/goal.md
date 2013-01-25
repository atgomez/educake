---
title: Goal
---

<h1>Goal APIs</h1>

* TOC
{:toc}

## Get list goals

<pre><code>GET /api/v1/goals/:student_id</code></pre>

### Parameters

student_id
: _required_ **integer** - The student's ID.

page_id
: _optional_ **integer** - The page index.

page_size
: _optional_ **integer** - The total items per page will be returned.

  - Default value is `20` items.
  - Maximum value is `100`. If you pass a number greater than `100`, the returned items will be limited at `100`.

### Response

<%= json_string \
  %({
      "total_pages":1,
      "current_page":1,
      "data":[
        {
           "accuracy":90.0,
           "baseline":20.0,
           "baseline_date":"2012-11-01",
           "curriculum_id":5,
           "description":" Ad corrupti quisquam a consequuntur in occaecati et. Soluta nam ut architecto delectus.",
           "due_date":"2013-11-01",
           "id":5,
           "is_completed":false,
           "student_id":1,
           "trial_days_actual":9,
           "trial_days_total":10
        },
        {
           "accuracy":90.0,
           "baseline":20.0,
           "baseline_date":"2012-11-01",
           "curriculum_id":4,
           "description":"Nesciunt perferendis unde nisi temporibus modi. Nemo consectetur id deserunt cum",
           "due_date":"2013-11-01",
           "id":4,
           "is_completed":false,
           "student_id":1,
           "trial_days_actual":9,
           "trial_days_total":10
        },
        {
           "accuracy":90.0,
           "baseline":20.0,
           "baseline_date":"2012-11-01",
           "curriculum_id":3,
           "description":"Et sunt consequatur enim adipisci est quaerat voluptas. Accusamus sed omnis.",
           "due_date":"2013-11-01",
           "id":3,
           "is_completed":false,
           "student_id":1,
           "trial_days_actual":9,
           "trial_days_total":10
        },
        {
           "accuracy":90.0,
           "baseline":20.0,
           "baseline_date":"2012-11-01",
           "curriculum_id":2,
           "description":"Sint nihil et temporibus voluptatem atque. Beatae aut maiores. Consequuntur animi dolores eius aut. Quisquam earum aliquid\n  voluptatem.",
           "due_date":"2013-11-01",
           "id":2,
           "is_completed":false,
           "student_id":1,
           "trial_days_actual":9,
           "trial_days_total":10
        },
        {
           "accuracy":90.0,
           "baseline":20.0,
           "baseline_date":"2012-11-01",
           "curriculum_id":1,
           "description":"Totam consequatur aut sit officiis in similique. Perferendis distinctio cumque.",
           "due_date":"2013-11-01",
           "id":1,
           "is_completed":false,
           "student_id":1,
           "trial_days_actual":9,
           "trial_days_total":10
        }
     ]
  })
%>

## Add grade for a goal

<pre><code>POST /api/v1/goals/:goal_id/add_grade</code></pre>

### Parameters

goal_id
: _required_ **integer** - The goal's ID.

### Post data

due_date
: _required_ **date** - Date when the grade created.
  
  - Date must be in format `mm-dd-yyyy`.

accuracy
: _required_ **float** - Value of the grade.

time_to_complete
: _optional_ **time** - Time to complete the grade.
  
  - Example: `5:30`.

note
: _optional_ **string** - Some extra description.

<%= headers(nil, "Content-Type" => "application/json") %>
<%= json \
  :due_date => "01-25-2013",
  :accuracy => 25,
  :time_to_complete => "5:30",
  :note => "Final exercise"
%>

### Response

#### Success

<%= json_string \
  %({
     "accuracy":10.0,
     "due_date":"2012-11-03",
     "goal_id":16,
     "id":1,
     "note":null,
     "time_to_complete":null,
     "user_id":13
  }), 201
%>

#### Errors

<%= json_string \
  %({"error":["Due date must be less than or equal to goal due date"]}), 400
%>
