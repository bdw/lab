# BDWs lab files

Just some toys/lab implementations of ideas.

# Queue Tutorial

These files hold the 'queue tutorial' I'm hoping to write someday soon.
Concurrent queue's are possibly the most useful data structure in
concurrent programming, making the composition of concurrent programs
relatively simple.

# Concurrent Merge Sort 

This is a repository containing a concurrent implementation of merge
sort.
[captaincronos](https://github.com/captaincronos/algos/blob/master/sort/merge/pmerge/pmerge.go)
used another strategy which is interesting. I've written this as a
part of a tutorial-to-write.

The current implementation of ConcurrentMergeSort is actually slower
than the iterative implementation, which is the current
fastest. However it actually speeds up using multiple cores, so that
is a begin. To test use the following command in the source directory:

   go test -bench . -cpu 1,2,4

I think we can improve upon this design, however my goal was to get
something working as simple as possible. Also note that the recursive
merge sort implementation is naive by design.

=======
mini-todo
=========

Todo list in &lt; 100 Lines of javascript. 

This is to show what can be done using just the DOM and a bit of cleverness.
