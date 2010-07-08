From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 08 Jul 2010 17:46:55 +0200
Subject: [PATCH 6/6] Exit status 0 for 'dmsetup -c -o help'
In-Reply-To: <20100707181602.GC22664@agk-dp.fab.redhat.com>
References: <cover.1278505444.git.zkabelac@redhat.com>	<021570bdb0ff125d08c6b92a411fc34a02ef48c2.1278505444.git.zkabelac@redhat.com>
	<20100707181602.GC22664@agk-dp.fab.redhat.com>
Message-ID: <4C35F2EF.1080608@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 7.7.2010 20:16, Alasdair G Kergon napsal(a):
> On Wed, Jul 07, 2010 at 02:29:36PM +0200, Zdenek Kabelac wrote:
>> diff --git a/tools/dmsetup.c b/tools/dmsetup.c
>> index 5e71542..479cbb0 100644
>> --- a/tools/dmsetup.c
>> +++ b/tools/dmsetup.c
>> @@ -3340,6 +3340,7 @@ int main(int argc, char **argv)
>>   	}
>>
>>   	if (argc == 0) {
>> +		r = 0;
>>   		_usage(stderr);
>>   		goto out;
>
> How does that work?
>
> # dmsetup
>
> Should give failure status.
> (It already does.)
>
> # dmsetup help
>
> Should give success.
> (It already does.)
>
> # dmsetup -c -o help
>
> Should give success.
> (It doesn't.)
>


Here is second try to address only this explicit problem:

_report_init() is able to return 1 for 'help'/'?'
(same check is in libdm-report.c)
Following checks detects that 'info' invoked it.

What still looks weird is 'dmsetup ls -c -o help' - which returns 1 - but 
displays meaningless help message for this command, (but this is not 
influenced by this patch).

Zdenek


Index: tools/dmsetup.c
===================================================================
RCS file: /cvs/lvm2/LVM2/tools/dmsetup.c,v
retrieving revision 1.141
diff -u -p -r1.141 dmsetup.c
--- tools/dmsetup.c	8 Jul 2010 14:29:28 -0000	1.141
+++ tools/dmsetup.c	8 Jul 2010 15:40:35 -0000
@@ -2652,6 +2652,9 @@ static int _report_init(struct command *
  	r = 1;

  out:
+	if (!strcasecmp(options, "help") || !strcmp(options, "?"))
+		r = 1;
+
  	if (len)
  		dm_free(options);

@@ -3360,8 +3363,15 @@ int main(int argc, char **argv)
  	if (!_switches[COLS_ARG] && !strcmp(c->name, "splitname"))
  		_switches[COLS_ARG]++;

-	if (_switches[COLS_ARG] && !_report_init(c))
-		goto out;
+	if (_switches[COLS_ARG]) {
+		if (!_report_init(c))
+			goto out;
+		if (!_report) {
+			if (!strcmp(c->name, "info"))
+				r = 0;  /* info -c -o help */
+			goto out;
+		}
+	}

  	#ifdef UDEV_SYNC_SUPPORT
  	if (!_set_up_udev_support(dev_dir))



