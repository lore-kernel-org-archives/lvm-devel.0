From: Eric Ren <zren@suse.com>
Date: Thu, 14 Dec 2017 18:27:39 +0800
Subject: [PATCH] test: lvmetad_dump always timed out when using nc
In-Reply-To: <20171213111303.24775-1-zren@suse.com>
References: <20171213111303.24775-1-zren@suse.com>
Message-ID: <02180207-fc63-f9c2-64b0-82224eef1a3e@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi zkabelac,

Hmm strange, tested on fedora, it has not this issue.

```

[root at localhost test]# which oscat
/usr/bin/which: no oscat in 
(/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin)

[root at localhost test]# lib/runner --flavours udev-lvmetad --only 
lvmetad-dump.sh
running 1 tests
###?????? passed: [udev-lvmetad] shell/lvmetad-dump.sh 3
### 1 tests: 1 passed, 0 skipped, 0 timed out, 0 warned, 0 failed

```

I guess it may be because openSUSE and fedora use different "nc" tool:

```

openSUSE:

# rpm -qf /usr/bin/nc
netcat-openbsd-1.178-1.2.x86_64

fedora:
# rpm -qf /usr/bin/nc
nmap-ncat-7.50-3.fc27.x86_64

```

Thanks,
Eric


On 12/13/2017 07:13 PM, Eric Ren wrote:
> lvmetad_dump uses either "socat" or "nc" to communicate
> with lvmetad. But when using "nc" if "socat" is not
> available, nc will listen forever by default, causing the
> testcase timed out.
>
> Signed-off-by: Eric Ren <zren@suse.com>
> ---
>   test/lib/aux.sh | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/test/lib/aux.sh b/test/lib/aux.sh
> index 6bc7bd47e..4603c1504 100644
> --- a/test/lib/aux.sh
> +++ b/test/lib/aux.sh
> @@ -243,14 +243,14 @@ lvmetad_talk() {
>   	local use=nc
>   	if type -p socat >& /dev/null; then
>   		use=socat
> -	elif echo | not nc -U "$TESTDIR/lvmetad.socket" ; then
> +	elif echo | not nc -w 1 -U "$TESTDIR/lvmetad.socket" ; then
>   		echo "WARNING: Neither socat nor nc -U seems to be available." 1>&2
>   		echo "## failed to contact lvmetad."
>   		return 1
>   	fi
>   
>   	if test "$use" = nc ; then
> -		nc -U "$TESTDIR/lvmetad.socket"
> +		nc -w 1 -U "$TESTDIR/lvmetad.socket"
>   	else
>   		socat "unix-connect:$TESTDIR/lvmetad.socket" -
>   	fi | tee -a lvmetad-talk.txt


