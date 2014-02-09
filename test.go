package mergesort

import (
	"testing"
	"math/rand"
)

func TestRecursiveMergeSort(t *testing.T) {
	sample := rand.Perm(65536)
	sorted := RecursiveMergeSort(sample)
	for i := 1; i < len(sorted); i++ {
		if sorted[i-1] > sorted[i] {
			t.Fatal("not in sorted order")
		}
	}
}


