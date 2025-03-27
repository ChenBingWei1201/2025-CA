# HW1

## Problem 2: LIS Algorithm
C's mindset:
```c
int max(int a, int b) {
    return (a > b) ? a : b;
}

int main() {
	for(int i = 1; i < n; i++) {
	  for(int j = 0; j < i; j++) {
	    if(arr[j] < arr[i]) {
	      lis[i] = max(lis[i], lis[j] + 1);
	    }
	  }
	}

	int maximum = 0;
	for(int i = 0; i < n; i++) {
	  if(lis[i] > maximum) {
	    maximum = lis[i];
	  }
	}
}
```

Assembly's mindset:
```c
int maximum = 0;

void findMax(int n, int* lis) {
	int i = 0;
	while(true) {
		if (i >= n) {
			break;
		}

		if (maximum >= lis[i]) {
			i++;
			continue;
		}

		maximum = lis[i];
		i++;
	}
}

int main() {
	int i = 1;
	while(true) {
		if (i >= n) {
			break;
		}
		int j = 0;
		while(true) {
			if (j >= i) {
				break;
			}

			if (arr[j] >= arr[i]) {
				j++;
				continue;
			}
			if (lis[i] >= lis[j] + 1) {
				j++;
				continue;
			}
			lis[i] = lis[j] + 1;
			j++;
		}
		i++;
	}

	findMax(n, lis);
	return 0;
}
```