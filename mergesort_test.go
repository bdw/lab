package mergesort_test

import (
	"testing"
	"math/rand"
	. "mergesort"
)

func testSortOrder(values []int) bool {
	for i := 1; i < len(values); i++ {
		if values[i] < values[i-1] {
			return false
		}
	}
	return true
}


func TestRecursiveMergeSort(t *testing.T) {
	sample := rand.Perm(65536)
	sorted := RecursiveMergeSort(sample)
	if !testSortOrder(sorted) {
		t.Error("RecursiveMergeSort; not in sort order")
	}
}


func TestIterativeMergeSort(t *testing.T) {
	sample := rand.Perm(65536)
	sorted := IterativeMergeSort(sample)
	if !testSortOrder(sorted) {
		t.Error("IterativeMergeSort: not in sort order")
	}

}
