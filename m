From: Zhen Ren <zren@suse.com>
Date: Fri, 17 Feb 2017 17:58:51 -0700
Subject: Question about the fix "clvmd: Fix freeze if client dies holding locks"
Message-ID: <58A836FB020000D40008F988@prv-mh.provo.novell.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Alasdair,

After back porting this fix, cLVMD segfault happened several time randomly during my testing.
"""
[3719.432586] clvmd[4404] trap stack segment ip:40b56f sp:7fff283a9db0 error:0 in clvmd[400000+9d000]
[ 5371.552854] clvmd[9819] trap stack segment ip:40b56f sp:7ffef80524f0 error:0 in clvmd[400000+9d000]
"""

The core dump shows segfault happened at  at clvmd.c:898:

"""
* 1    Thread 0x7f66d34187a0 (LWP 4404) 0x000000000040b56f in main_loop (local_sock=<optimized out>, 
    cmd_timeout=<optimized out>) at clvmd.c:898
(gdb) bt
#0  0x000000000040b56f in main_loop (local_sock=<optimized out>, cmd_timeout=<optimized out>) at clvmd.c:898
#1  0x000000000040c454 in main (argc=<optimized out>, argv=<optimized out>) at clvmd.c:615
(gdb) frame 0
#0  0x000000000040b56f in main_loop (local_sock=<optimized out>, cmd_timeout=<optimized out>) at clvmd.c:898
898                                                FD_SET(thisfd->fd, &in);
"""

The "thisfd->fd" is very weird:

"""
(gdb) p *thisfd
$2 = {fd = -1073735264, type = 32614, next = 0x7f66c0000178, xid = 13040, 
  callback = 0x40df10 <local_pipe_callback>, removeme = 0 '\000', bits = {localsock = {replies = 0x7f66c0002200, 
      num_replies = 0, expected_replies = 0, sent_time = 0, in_progress = -1073715552, sent_out = 32614, 
      private = 0x0, cmd = 0x0, cmd_len = 0, pipe = 0, finished = 0, all_success = 0, cleanup_needed = 0, 
      pipe_client = 0x2074656b, threadid = 3833161679754913132, state = PRE_COMMAND, mutex = {__data = {
          __lock = -1073728512, __count = 32614, __owner = 0, __nusers = 0, __kind = -1073728016, 
          __spins = 32614, __list = {__prev = 0x7f66c00035f0, __next = 0x0}}, 
        __size = "\000\064\000\300f\177\000\000\000\000\000\000\000\000\000\000\360\065\000\300f\177\000\000\360\065\000\300f\177\000\000\000\000\000\000\000\000\000", __align = 140079284630528}, cond = {__data = {
          __lock = -1073728016, __futex = 32614, __total_seq = 140079284631079, __wakeup_seq = 140080358359039, 
          __woken_seq = 0, __mutex = 0x7f66c00055f0, __nwaiters = 3522823072, __broadcast_seq = 32614}, 
        __size = "\360\065\000\300f\177\000\000'6\000\300f\177\000\000\377\377\377\377f\177\000\000\000\000\000\000\000\000\000\000\360U\000\300f\177\000\000\240\003\372\321f\177\000", __align = 140079284631024}, reply_mutex = {
        __data = {__lock = -775253632, __count = 32614, __owner = -775253856, __nusers = 32614, 
          __kind = 674859888, __spins = 32767, __list = {__prev = 0x7fff28398b68, __next = 0x110}}, 
        __size = "\200\221\312\321f\177\000\000\240\220\312\321f\177\000\000p\213\071(\377\177\000\000h\213\071(\377\177\000\000\020\001\000\000\000\000\000", __align = 140079583105408}}, pipe = {client = 0x7f66c0002200, 
      threadid = 0}, net = {private = 0x7f66c0002200, flags = 0}}}
'"""

I still cannot find out what is the root cause after looking the code around, only to be confused with "lastfd" in your patch,
which is assigned at 3 times, but never used.

"""
struct local_client *lastfd = &local_client_head;
...
lastfd->next = nextfd;
...
  lastfd = thisfd
"""

Could you please take a look at this?

Best regards,
Eric



