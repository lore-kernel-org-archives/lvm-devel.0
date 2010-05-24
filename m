From: Petr Rockai <prockai@redhat.com>
Date: Mon, 24 May 2010 17:11:07 +0200
Subject: [PATCH]: Added installcheck target in Makefiles
In-Reply-To: <4BF69421.9040407@redhat.com> (Marian Csontos's message of "Fri, 
	21 May 2010 16:09:37 +0200")
References: <4BF69421.9040407@redhat.com>
Message-ID: <87pr0libck.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

a couple of issues, see comments inline.

> --- Makefile.in	13 Apr 2010 13:28:52 -0000	1.52
> +++ Makefile.in	21 May 2010 13:34:58 -0000
> @@ -75,9 +75,14 @@
>  endif
>  DISTCLEAN_TARGETS += cscope.out
>  
> +.PHONY: check check_cluster check_local installcheck installcheck_cluster installcheck_local
> +
>  check check_cluster check_local: all
>  	$(MAKE) -C test $(@)
>  

[snip]

> --- test/Makefile.in	12 May 2010 11:59:46 -0000	1.42
> +++ test/Makefile.in	21 May 2010 13:34:59 -0000
> @@ -46,47 +46,63 @@
>  	$(MAKE) -C api vgtest
>  endif
>  
> -all check: init.sh
> -	@echo Testing with locking_type 1
> -	./bin/harness $(RUN)
> -	@echo Testing with locking_type 3
> -	LVM_TEST_LOCKING=3 ./bin/harness $(RUN)
> +.PHONY: all \
> +  check check_cluster check_local \
> +  installcheck installcheck_cluster installcheck_local \
> +  clean distclean
The .PHONY additions should be a separate patch, arguably. Not directly
related installcheck?

> -check_cluster: init.sh
> +all check: check_local check_cluster
> +
> +check_cluster: init.sh .bin-dir-stamp
>  	@echo Testing with locking_type 3
> -	LVM_TEST_LOCKING=3 ./bin/harness $(RUN)
> +	INSTALLCHECK= LVM_TEST_LOCKING=3 ./bin/harness $(RUN)
>  
> -check_local: init.sh
> +check_local: init.sh .bin-dir-stamp
>  	@echo Testing with locking_type 1
> -	LVM_TEST_LOCKING=1 ./bin/harness $(RUN)
> +	INSTALLCHECK= LVM_TEST_LOCKING=1 ./bin/harness $(RUN)
> +
> +installcheck: installcheck_local installcheck_cluster
> +
> +installcheck_cluster: init.sh
> +	@echo Testing installation with locking_type 3
> +	INSTALLCHECK=1 LVM_TEST_LOCKING=3 ./bin/harness $(RUN)
> +
> +installcheck_local: init.sh
> +	@echo Testing installation with locking_type 1
> +	INSTALLCHECK=1 LVM_TEST_LOCKING=1 ./bin/harness $(RUN)
Since this is leaked into global environment, the name should start with
LVM_TEST_ like with other envvars that control the testsuite (probably
LVM_TEST_INSTALLED?). Another option is to use a different mechanism.

> +bin:
> +	mkdir bin
>  
> -bin/not: $(srcdir)/not.c .bin-dir-stamp
> -	$(CC) -o bin/not $<
> +bin/not: $(srcdir)/not.c Makefile bin
> +	$(CC) -o $@ $<
>  	ln -sf not bin/should
>  
> -bin/harness: $(srcdir)/harness.c .bin-dir-stamp
> -	$(CC) -o bin/harness $<
> +bin/harness: $(srcdir)/harness.c Makefile bin
> +	$(CC) -o $@ $<
>  
> -bin/check: $(srcdir)/check.sh .bin-dir-stamp
> -	cp $< bin/check
> -	chmod +x bin/check
> +bin/check: $(srcdir)/check.sh Makefile bin
> +	cp $< $@
> +	chmod +x $@
Why are those changes in this patch? Same as with PHONY above.

> -init.sh: $(srcdir)/Makefile.in .bin-dir-stamp bin/not bin/check bin/harness $(SCRIPTS)
> +init.sh: Makefile bin/not bin/check bin/harness $(SCRIPTS)
>  	rm -f $@-t $@
>  	echo 'top_srcdir=$(top_srcdir)' >> $@-t
>  	echo 'abs_top_builddir=$(abs_top_builddir)' >> $@-t
>  	echo 'abs_top_srcdir=$(abs_top_builddir)' >> $@-t
> +	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
> +	echo 'abs_builddir=$(abs_builddir)' >> $@-t
>  	echo 'PATH=$$abs_top_builddir/test/bin:$$PATH' >> $@-t
> +	echo 'if test -z "$$INSTALLCHECK"; then' >> $@-t
> +	echo '  PATH=$$abs_top_builddir/test/sbin:$$PATH' >> $@-t
Why sbin? Looks unrelated and superfluous.

>  	LDLPATH="\$$abs_top_builddir/libdm"; \
>  	LDLPATH="$$LDLPATH:\$$abs_top_builddir/tools"; \
>  	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd"; \
>  	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd/plugins/lvm2"; \
>  	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd/plugins/mirror"; \
>  	LDLPATH="$$LDLPATH:\$$abs_top_builddir/daemons/dmeventd/plugins/snapshot"; \
> -	echo "export LD_LIBRARY_PATH=\"$$LDLPATH\"" >> $@-t
> -	echo 'top_srcdir=$(top_srcdir)' >> $@-t
> -	echo 'abs_srcdir=$(abs_srcdir)' >> $@-t
> -	echo 'abs_builddir=$(abs_builddir)' >> $@-t
> +	echo "  export LD_LIBRARY_PATH=\"$$LDLPATH\"" >> $@-t
> +	echo 'fi' >> $@-t
>  	echo 'export PATH' >> $@-t
>  	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
>  	chmod a-w $@-t
Other than the sbin bit, this is the actual relevant change -- do not
override PATH and LD_LIBRARY_PATH for the tests if INSTALLCHECK is set
in the environment (see above wrt naming).

> @@ -95,16 +111,18 @@
>  
>  Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
>  	cd $(top_builddir) && $(SHELL) ./config.status $(subdir)/$@
> +	echo 'Makefile rebuilt! Run again....' >&2
> +	exit 1

This does not look very canonic. It is probably also quite superfluous.
>From GNU make manual, section 3.7:
| To this end, after reading in all makefiles, make will consider each
| as a goal target and attempt to update it. If a makefile has a rule
| which says how to update it (found either in that very makefile or in
| another one) or if an implicit rule applies to it (see Using Implicit
| Rules), it will be updated if necessary. After all makefiles have been
| checked, if any have actually been changed, make starts with a clean
| slate and reads all the makefiles over again. (It will also attempt to
| update each of them over again, but normally this will not change them
| again, since they are already up to date.)

>  .bin-dir-stamp: lvm-wrapper
> -	rm -rf bin
> -	mkdir bin
> +	rm -rf sbin
> +	mkdir sbin
>  	for i in lvm $$(cat ../tools/.commands); do \
> -	  ln -s ../lvm-wrapper bin/$$i; \
> +	  ln -s ../lvm-wrapper sbin/$$i; \
>  	done
> -	ln -s "$(abs_top_builddir)/tools/dmsetup" bin/dmsetup
> -	ln -s "$(abs_top_builddir)/daemons/clvmd/clvmd" bin/clvmd
> -	ln -s "$(abs_top_builddir)/daemons/dmeventd/dmeventd" bin/dmeventd
> +	ln -s "$(abs_top_builddir)/tools/dmsetup" sbin/dmsetup
> +	ln -s "$(abs_top_builddir)/daemons/clvmd/clvmd" sbin/clvmd
> +	ln -s "$(abs_top_builddir)/daemons/dmeventd/dmeventd" sbin/dmeventd
Just bin -> sbin again.

> @@ -118,7 +136,7 @@
>  	mv $@-t $@
>  
>  clean:
> -	rm -rf init.sh lvm-wrapper bin .bin-dir-stamp
> +	rm -rf init.sh lvm-wrapper bin sbin .bin-dir-stamp
>  	if test "$(srcdir)" != . ; then rm -f $(subst $(srcdir)/, ,$(SCRIPTS)) lvm2app.sh ; fi
>  
>  distclean: clean

> diff -a -u -r1.9 t-000-basic.sh
> --- test/t-000-basic.sh	20 Apr 2010 15:19:36 -0000	1.9
> +++ test/t-000-basic.sh	21 May 2010 13:34:59 -0000
> @@ -18,7 +18,11 @@
>  lvm pvmove --version|sed -n "1s/.*: *\([0-9][^ ]*\) .*/\1/p" > actual
>  
>  # ensure they are the same
> -diff -u actual expected
> +if test -z "$INSTALLCHECK"; then
> +  diff -u actual expected
> +else
> +  should diff -u actual expected
> +fi
Makes sense.

Please separate out the actual relevant changes and submit again. I
think that can go in. I don't see the reasoning behind "sbin", but I am
not opposed to the other refactors -- but please submit them separately.

Thanks,
   Petr.


