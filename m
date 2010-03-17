From: Petr Rockai <prockai@redhat.com>
Date: Wed, 17 Mar 2010 11:07:04 +0100
Subject: [PATCH] testsuite: get stacktrace if test drops core
In-Reply-To: <20100316204454.GA25921@redhat.com> (Mike Snitzer's message of
	"Tue, 16 Mar 2010 16:44:54 -0400")
References: <20100316204454.GA25921@redhat.com>
Message-ID: <87vdcv8do7.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Mike Snitzer <snitzer@redhat.com> writes:
> Requires lvm be built with debugging (-g).
> Also requires ulimit -c be non-zero (to drop core file).
>
> diff --git a/test/test-utils.sh b/test/test-utils.sh
> index 6606c56..06b9636 100644
> --- a/test/test-utils.sh
> +++ b/test/test-utils.sh
> @@ -24,6 +24,21 @@ STACKTRACE() {
>  		echo "$i ${FUNC}() called from ${BASH_SOURCE[$i]}:${BASH_LINENO[$i]}"
>  		i=$(($i + 1));
>  	done
> +
> +	# Attempt to get a stacktrace if a core file exists
> +	# and the lvm binary was built with debugging
> +	TEST_LVM_BINARY=$(dirname $(which lvm))/../../tools/lvm
> +	TEST_LVM_CORE=`ls core* | head -1`
> +	GDB_BINARY=`which gdb`
> +	READELF_BINARY=`which readelf`
> +	if [ -n "$TEST_LVM_CORE" -a -n "$GDB_BINARY" -a -n "$READELF_BINARY" ]; then
> +		if $READELF_BINARY -S $TEST_LVM_BINARY 2>&1 | grep -q .debug_info; then
> +			echo bt > gdb_commands.txt
> +			echo l >> gdb_commands.txt
> +			echo quit >> gdb_commands.txt
> +			$GDB_BINARY -batch -c $TEST_LVM_CORE -x gdb_commands.txt $TEST_LVM_BINARY
> +		fi
> +	fi
>  }
>  
>  init_udev_transaction() {
Looks good to me. Maybe change "bt" to "bt full"? That would also list
local variables on the stack, so more useful data. (Maybe even make it
"thread apply all bt full", although we don't currently use threads here
and we don't handle dmeventd coredumps either... maybe later.)

Otherwise, ACK.

Yours,
   Petr.


