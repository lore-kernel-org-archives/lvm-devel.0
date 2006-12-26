From: Shinn'ya Hoshino <hoshino-s@ma.dnes.nec.co.jp>
Date: Tue, 26 Dec 2006 15:06:37 +0900
Subject: Why print_log() is doing the memlock check?
In-Reply-To: <20061217115801.GB4982@agk.surrey.redhat.com>
References: <20061217115801.GB4982@agk.surrey.redhat.com>
Message-ID: <20061226150637hoshino-s@mail.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thanks for reply.

Alasdair G Kergon <agk@redhat.com> wrote:
> While i/o is suspended you could have a situation where
> most of the rest of the system blocks up until i/o is
> resumed,

However, when a trouble occurs in the server currently used 
for business, it needs to avoid that it becomes impossible to 
investigate in order that there may be no log.

If logging is suspended until unlocked, does it solve?

When it is true, I shall want to consider the addition which 
suspends logging.

/* -------------------------------------------------------------
  Shinn'ya Hoshino          mailto:hoshino-s at ma.dnes.nec.co.jp
------------------------------------------------------------- */


