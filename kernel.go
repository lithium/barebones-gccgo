package kernel

import "unsafe"

func Main() {
	var color uint8 = 7;
	var buffer uintptr = 0xB8000;

	msg := "hello, kernel"

	for i := 0; i < len(msg); i++ {
		offset := i
		addr := (*uint16)(unsafe.Pointer(buffer + 2 * uintptr(offset)))
		*addr = uint16(msg[i]) | uint16(color) << 8
	}
}

