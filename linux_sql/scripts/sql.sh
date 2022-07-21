#! /bin/bash

psql -h localhost -U postgres -W

SELECT * FROM host_info
