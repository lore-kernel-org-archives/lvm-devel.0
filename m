From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 17 Dec 2006 11:58:01 +0000
Subject: Why print_log() is doing the memlock check?
In-Reply-To: <20061215183200hoshino-s@mail.jp.nec.com>
References: <20061215183200hoshino-s@mail.jp.nec.com>
Message-ID: <20061217115801.GB4982@agk.surrey.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Dec 15, 2006 at 06:32:00PM +0900, Shinn'ya Hoshino wrote:
> I am testing a writing error message to the /var/log/messages.
> However, a part of the error message wasn't written.
> It's blocked by memlock() function in print_log() function in lib/log.c.
 
LVM2 metadata changes go:
  suspend i/o to  device
  flip to new metadata
  resume i/o

While i/o is suspended you could have a situation where
most of the rest of the system blocks up until i/o is
resumed, so it is vital that the process that is going
to perform the resume does not itself also block up.
Writing a log message can lead to that, so logging
is disabled in such critical sections.

Override for testing with log/activation set to 1 in the config.

Alasdair
-- 
agk at redhat.com


