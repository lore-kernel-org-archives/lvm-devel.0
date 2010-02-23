From: Jakub Jelinek <jakub@redhat.com>
Date: Tue, 23 Feb 2010 17:28:42 +0100
Subject: lvm and locales memory issue
In-Reply-To: <4B83F193.9020209@redhat.com>
References: <4B7D372D.4060608@redhat.com> <4B7D4014.3010205@redhat.com>
	<4B7EB81D.6090405@redhat.com>
	<20100219163008.GR27427@agk-dp.fab.redhat.com>
	<4B8262A2.4050408@redhat.com> <4B8283B6.7000808@redhat.com>
	<20100222181150.GA32020@agk-dp.fab.redhat.com>
	<20100222182301.GR2817@tyan-ft48-01.lab.bos.redhat.com>
	<4B839743.8020909@redhat.com> <4B83F193.9020209@redhat.com>
Message-ID: <20100223162842.GC2817@tyan-ft48-01.lab.bos.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Feb 23, 2010 at 04:17:39PM +0100, Zdenek Kabelac wrote:
> It looks like cs_CZ.utf8/LC_MESSAGES/SYS_LC_MESSAGES  is just 59 bytes.
> There is something seriously wrong with the current glibc optimalization to
> have 100MB locked into memory if you want to use 59 bytes from this file....

LC_MESSAGES contains just yesstr/nostr definition, nothing else.
But guess your application isn't asking just for LC_MESSAGES category...

> Looking at the size of /usr/share/i18n/locales/cs_CZ - one may start to wonder
> why Czech locales are defining collates for arabic latin and other 'related'
> laguages, while in German there is simple 'copy "iso14651_t1"'

iso14651_t1 defines collation for all kinds of charsets, ideally cs_CZ
should just include that file too and tweak afterwards for the differences
Czech ordering requires.

> Another note could be - Ubuntu does not even use locale-archive file and uses
> locales on per file basis - so now I'm getting curious, where are the tests,

Not everything Ubuntu does is necessarily a good idea.

> that proves that Fedora gets some measurable performance advantage?

Try something trivial, like:
#include <locale.h>

int
main (void)
{
  int i;
  for (i = 0; i < 1000000; i++)
    switch (i % 5)
      {
      case 0: setlocale (LC_ALL, "C"); break;
      case 1: setlocale (LC_ALL, "en_US.UTF-8"); break;
      case 2: setlocale (LC_ALL, "cs_CZ.UTF-8"); break;
      case 3: setlocale (LC_ALL, "fr_FR.UTF-8"); break;
      case 4: setlocale (LC_ALL, "de_DE.UTF-8"); break;
      }
  return 0;
}

With locale-archive 1.362s, without, using locale files, 10.355s.  And
that is not even using a locale name that needs alias lookup, which would
need parsing of locale.alias too.  As this is something almost
every program calls@least once, it is not a good idea to slow this down
completely unnecessarily.

	Jakub


