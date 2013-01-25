---
title: Student
---

<h1>Student APIs</h1>

* TOC
{:toc}

## Get list students

<pre><code>GET /api/v1/students</code></pre>

### Parameters

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
           "birthday":"1997-01-25",
           "first_name":"Julie",
           "gender":null,
           "id":7,
           "last_name":"Greenfelder",
           "teacher_id":17,
           "photo_url":"default-avatar.jpeg"
        },
        {
           "birthday":"1997-01-25",
           "first_name":"Mandy",
           "gender":null,
           "id":4,
           "last_name":"King",
           "teacher_id":17,
           "photo_url":"default-avatar.jpeg"
        },
        {
           "birthday":"1997-01-25",
           "first_name":"Alba",
           "gender":null,
           "id":5,
           "last_name":"Schoen",
           "teacher_id":17,
           "photo_url":"default-avatar.jpeg"
        },
        {
           "birthday":"1997-01-25",
           "first_name":"Rosanna",
           "gender":null,
           "id":6,
           "last_name":"Schultz",
           "teacher_id":17,
           "photo_url":"default-avatar.jpeg"
        },
        {
           "birthday":"1997-01-25",
           "first_name":"Jayme",
           "gender":null,
           "id":8,
           "last_name":"Towne",
           "teacher_id":17,
           "photo_url":"default-avatar.jpeg"
        }
     ]
  })
%>
