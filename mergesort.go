package mergesort

func Merge(a, b, c []int) {
	var i, j, k int
	for i < len(a) && j < len(b) {
		if (a[i] < b[j]) {
			c[k] = a[i]
			i += 1
		} else {
			c[k] = b[j]
			j += 1
		}
		k += 1
	}
	for i < len(a) {
		c[k] = a[i]
		i += 1
		k += 1
	}
	for j < len(b) {
		c[k] = b[j]
		j += 1
		k += 1
	}
}

func RecursiveMergeSort(values []int) []int {
	if len(values) > 2 {
		mid := len(values) / 2
		left := RecursiveMergeSort(values[:mid])
		right := RecursiveMergeSort(values[mid:])
		space := make([]int, len(values))
		Merge(left, right, space)
		return space
	} else if len(values) == 2 {
		if values[0] > values[1] {
			values[0], values[1] = values[1], values[0]
		}
		return values
	} else {
		return values
	}
}

