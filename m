From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 22 Feb 2010 18:11:50 +0000
Subject: lvm and locales memory issue
In-Reply-To: <4B8283B6.7000808@redhat.com>
References: <4B7D063A.7070601@redhat.com> <4B7D372D.4060608@redhat.com>
	<4B7D4014.3010205@redhat.com> <4B7EB81D.6090405@redhat.com>
	<20100219163008.GR27427@agk-dp.fab.redhat.com>
	<4B8262A2.4050408@redhat.com> <4B8283B6.7000808@redhat.com>
Message-ID: <20100222181150.GA32020@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Feb 22, 2010 at 02:16:38PM +0100, Zdenek Kabelac wrote:
> On 22.2.2010 11:55, Zdenek Kabelac wrote:
> > 'rm -f /usr/lib/locale/locale-archive'
> > 'localedef -f UTF-8 -i cs_CZ /usr/lib/locale/cs_CZ.utf8'
> > 'localedef -i cs_CZ -c -f UTF-8 -A /usr/share/locale/locale.alias cs_CZ.UTF-8'

%attr(0644,root,root) %verify(not md5 size mtime mode) %ghost %config(missingok,noreplace) %{_prefix}/lib/locale/locale-archive

So removing/changing that file is a fully-supported process?

Perhaps anaconda should automatically remove it (if it has not been customised) on
any system with < 640MB RAM?

Or, better, the RPM could be updated not to install it on low-memory systems.

Alasdair


