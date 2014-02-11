package mergesort

import (
	"testing"
	"math/rand"
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

func TestConcurrentMergeSort(t *testing.T) {
	sample := rand.Perm(65536)
	sorted := ConcurrentMergeSort(sample)
	if !testSortOrder(sorted) {
		t.Error("ConcurrentMergeSort: not in sort order")
	}
}

func BenchmarkRecursiveMergeSort(b *testing.B) {
	for i := 0; i < b.N; i++ {
		b.StopTimer();
		sample := rand.Perm(65536)
		b.StartTimer()
		RecursiveMergeSort(sample)
	}
}

func BenchmarkIterativeMergeSort(b *testing.B) {
	for i := 0; i < b.N; i++ {
		b.StopTimer()
		sample := rand.Perm(65536)
		b.StartTimer()
		IterativeMergeSort(sample)
	}
}

func BenchmarkConcurrentMergeSort(b *testing.B) {
	for i := 0; i < b.N; i++ {
		b.StopTimer()
		sample := rand.Perm(65536)
		b.StartTimer()
		ConcurrentMergeSort(sample)
	}
}
