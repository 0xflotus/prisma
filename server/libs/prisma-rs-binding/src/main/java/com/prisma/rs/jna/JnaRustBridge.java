package com.prisma.rs.jna;

import com.sun.jna.Library;
import com.sun.jna.Pointer;

public interface JnaRustBridge extends Library {
    int select_1();
    void get_node_by_where(Pointer data, int len);
    void destroy(Pointer data);
}
