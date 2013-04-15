From: Petr Rockai <prockai@redhat.com>
Date: Mon, 15 Apr 2013 17:28:01 +0200
Subject: [lvm2-commits] master - Revert "cleanup: simplify option matching function"
In-Reply-To: <20130413012852.17E6D1558@fedorahosted.org> (Alasdair Kergon's
	message of "Sat, 13 Apr 2013 01:28:52 +0000 (UTC)")
References: <20130413012852.17E6D1558@fedorahosted.org>
Message-ID: <878v4jn79a.fsf@aldalome.mornfall.net>
	(sfid-20130415_172802_843083_6C5B359B)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Alasdair Kergon <agk@fedoraproject.org> writes:
> This reverts commit 0396ade38b88431d959ce02fac689306a2c47786.
>
> The original code also handled len==1, which the new code doesn't.
> Press <TAB> in the lvm shell to get a list of the possible
> flag completions for a single hyphen.

is there any chance of getting this in a form of a functional test?
Requirements in a machine-checked form are very useful. Every time we
have a regression like this (usually this happens because someone had no
idea that something was supposed to work) we should have a test that
checks for it, so we build up these, and avoid such mistakes in future.

Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


