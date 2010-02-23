From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 23 Feb 2010 16:53:30 +0000
Subject: lvm and locales memory issue
In-Reply-To: <20100223162842.GC2817@tyan-ft48-01.lab.bos.redhat.com>
References: <4B7D4014.3010205@redhat.com> <4B7EB81D.6090405@redhat.com>
	<20100219163008.GR27427@agk-dp.fab.redhat.com>
	<4B8262A2.4050408@redhat.com> <4B8283B6.7000808@redhat.com>
	<20100222181150.GA32020@agk-dp.fab.redhat.com>
	<20100222182301.GR2817@tyan-ft48-01.lab.bos.redhat.com>
	<4B839743.8020909@redhat.com> <4B83F193.9020209@redhat.com>
	<20100223162842.GC2817@tyan-ft48-01.lab.bos.redhat.com>
Message-ID: <20100223165330.GB560@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Feb 23, 2010 at 05:28:42PM +0100, Jakub Jelinek wrote:
>   for (i = 0; i < 1000000; i++)
>     switch (i % 5)
>       {
>       case 0: setlocale (LC_ALL, "C"); break;
>       case 1: setlocale (LC_ALL, "en_US.UTF-8"); break;
>       case 2: setlocale (LC_ALL, "cs_CZ.UTF-8"); break;
>       case 3: setlocale (LC_ALL, "fr_FR.UTF-8"); break;
>       case 4: setlocale (LC_ALL, "de_DE.UTF-8"); break;
>       }
>   return 0;
> }
> 
> As this is something almost
> every program calls at least once, it is not a good idea to slow this down
> completely unnecessarily.
 
Indeed - but lvm only calls this once, not a million times, so I'm afraid it's
the wrong optimisation for us.  Locale-based functions are anyway not used in
our performance-critical code paths.

An 80-90% saving on the memory footprint is a much more important consideration
for us.

Alasdair


