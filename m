From: Ben Sims <ben.sims@citrix.com>
Date: Tue, 29 Oct 2019 08:44:39 +0000
Subject: Performance regression between V2_02_177 and V2_02_180
In-Reply-To: <1571324396950.37136@citrix.com>
References: <1571324396950.37136@citrix.com>
Message-ID: <1572338679419.1072@citrix.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I'm not sure if anybody saw my original mail, there may have been a race condition with me actually joining the mailing list.


I can confirm the performance regression, is caused my async io, turning this off in the lvm.conf gets back my performance.

We work in a libaio intensive environment, so there is contention for libaio ring.


I'm wondering if libaio should be on by default?


Thanks,


Ben


________________________________
From: Ben Sims
Sent: 17 October 2019 15:59
To: lvm-devel@redhat.com
Subject: Performance regression between V2_02_177 and V2_02_180


Hi lvm-devel


I'm trying to analyze a performance regression in short lived commands such as lvchange.


V2_02_177


time /sbin/lvchange -ay /dev/abc/def


real    0m0.085s
user    0m0.000s
sys    0m0.013s


V2_02_180


time /sbin/lvchange -ay /dev/abc/def


real    0m0.115s
user    0m0.007s
sys    0m0.007s


I confirmed these measurements independently with perf over the course of a long test calling lvchange many times. The difference in individual calls is small but adds up.


The reg first occurred due to commit


commit db41fe6c5dab7ff66db9c0568f0e1e1b31657be3
Author: Alasdair G Kergon <agk@redhat.com>
Date:   Mon Jan 22 18:17:58 2018 +0000

    lvmcache: Use asynchronous I/O when scanning devices.


I notice that the new bcache is reading significantly more data 262144 bytes (two blocks of 131072 bytes from /dev/sda ) compared to 28672 bytes in 4k reads made in V2_02_177. Whats the rational for reading so much more data?


The extra overhead of this io estimated with strace does not appear to account for the slow down, but perhaps the processing of this data does?


I'm currently instrumenting the code, but thought i would ask on the mailing list.


Thanks,


Ben







-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20191029/902074bb/attachment.htm>
