From: Shinn'ya Hoshino <hoshino-s@ma.dnes.nec.co.jp>
Date: Mon, 22 Jan 2007 23:12:52 +0900
Subject: Why print_log() is doing the memlock check?
In-Reply-To: <20070109204824.GZ21980@agk.surrey.redhat.com>
References: <20070109204824.GZ21980@agk.surrey.redhat.com>
Message-ID: <20070122231252hoshino-s@mail.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> wrote:
> Date: Tue, 9 Jan 2007 20:48:24 +0000

> Another approach might be to cache the log messages in memory
> then write them out when exiting the critical section.

I am going to try it with static buffer.

Thanks, regards.

/* -------------------------------------------------------------
  Shinn'ya Hoshino          mailto:hoshino-s at ma.dnes.nec.co.jp
------------------------------------------------------------- */


