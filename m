From: Shinn'ya Hoshino <hoshino-s@ma.dnes.nec.co.jp>
Date: Fri, 15 Dec 2006 18:32:00 +0900
Subject: Why print_log() is doing the memlock check?
Message-ID: <20061215183200hoshino-s@mail.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Hello,

I am testing a writing error message to the /var/log/messages.
However, a part of the error message wasn't written.
It's blocked by memlock() function in print_log() function in lib/log.c.

lib/log.c:364
    if (_syslog && (_log_while_suspended || !memlock())) {
                                            ~~~~~~~~~~
        va_start(ap, format);
        vsyslog(level, trformat, ap);
        va_end(ap);
    }

I think that "memlock()" check is unnecessary.
Please teach me a reason why it is doing the memlock check.

Regards,

/* -------------------------------------------------------------
  Shinn'ya Hoshino          mailto:hoshino-s at ma.dnes.nec.co.jp
------------------------------------------------------------- */


