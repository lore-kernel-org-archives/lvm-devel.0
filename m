From: thornber@sourceware.org <thornber@sourceware.org>
Date: 21 Jul 2010 11:52:47 -0000
Subject: LVM2/unit-tests/regex TESTS matcher_t.expected ...
Message-ID: <20100721115247.16903.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	thornber at sourceware.org	2010-07-21 11:52:46

Modified files:
	unit-tests/regex: TESTS 
Added files:
	unit-tests/regex: matcher_t.expected2 random_regexes 

Log message:
	[REGEX] another matcher_t test with a larger set of regexes, only interested in the fingerprint

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/regex/matcher_t.expected2.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/regex/random_regexes.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/unit-tests/regex/TESTS.diff?cvsroot=lvm2&r1=1.1&r2=1.2

/cvs/lvm2/LVM2/unit-tests/regex/matcher_t.expected2,v  -->  standard output
revision 1.1
--- LVM2/unit-tests/regex/matcher_t.expected2
+++ -	2010-07-21 11:52:46.907122000 +0000
@@ -0,0 +1,2 @@
+Matcher built with 447 dfa states
+fingerprint: eed8ceb8
/cvs/lvm2/LVM2/unit-tests/regex/random_regexes,v  -->  standard output
revision 1.1
--- LVM2/unit-tests/regex/random_regexes
+++ -	2010-07-21 11:52:46.992980000 +0000
@@ -0,0 +1,100 @@
+"(((a?)(([Ub]*)|z))((([qr]|X)+)([Qn]*)))+"
+"[HZejtuw]*"
+"((B|s)*)|(((([Fv]l)(N+))(([el]|C)(tJ)))?)"
+"((([Ma]?)|(t*))*)|((([cm]E)|(M?))|(([BE][EV])|([Qj][Mh])))"
+"(((([bw]*)|([IO]*))((zK)*))|(((pU)|(i|q))|((z?)|([HL]?))))*"
+"((([Pt]?)|[Tr])?)((Hq)*)"
+"[HOXcfgikosvwxz]"
+"[BCEFGHNPTUWfjlprsy]"
+"((((aD)*)|([Xo]+))+)(([HKn](([Eq]|[JQ])(I*)))*)"
+"([LNWYeghv]|e)*"
+"(((y(L*))*)|((([EP]+)(W+))*))*"
+"U*"
+"((((R+)(W|[Qr]))|([py]+))+)([LM]*)"
+"(([DOjx](D(b?)))|([Ke]*))*"
+"((([ls](c|[FT]))*)([JS]*))*"
+"((l?)|(([Gz]+)|(D*)))*"
+"[ABgjn]"
+"(((q|[dg])?)|([Uk]*))((([Fl]?)|([Ry]+))|(([IR]|c)|(T?)))"
+"((([an]|P)|[Jw])((a*)|(m*)))*"
+"((((R[ht])(h+))?)|(([pz](n?))+))+"
+"(((([Dc]b)([Sp][Ii]))|((k|F)*))|[Uiovz])*"
+"[Res]*"
+"[Zl]|a"
+"^[ANZdf]$"
+"[En]|(((Q+)(U+))([pt]*))"
+"[ADEIMQUWXZhklrsvz]"
+"(((S(y*))*)|(j*))*"
+"n*"
+"[NUau]*"
+"((((Z*)(D|[Nd]))|(([np]|B)+))|(([Xy][Fi])*))+"
+"((([EZ]?)|(d[HR]))*)((([Hg]|q)(P+))*)"
+"q"
+"((m*)|(p|B))|((((x?)|(t+))(([Sb][PX])(O|[HM])))+)"
+"((((A*)(z[RS]))*)|(((z+)(Q*))+))*"
+"(((M*)([Uu]*))+)|[Uk]"
+"[imv]"
+"[GLSchtw](([Yw]((F[Dd])|([Tw]+)))?)"
+"([MOZj]*)(S|[Wknr])"
+"((G|q)*)[BHKN]"
+"((((NW)|([Ao]?))|((l|[UV])+))+)|((i|(z*))*)"
+"((((Z+)|([IR]?))|(L*))|([JKQ]+))+"
+"([Bdin](S*))+"
+"[HLNSTp]*"
+"(((J*)([Bq]|[Yu]))*)|([Kv]*)"
+"(((([BJ]|[Zy])(wI))*)(y*))+"
+"(((hF)+)|(H*))*"
+"((([QU][Pj])([GQ]?))+)|[PWo]"
+"(((([cq][BX])?)|((f[DI])*))*)(([GM]*)[SVYr])"
+"(([Zt]*)|((qx)|(([BV]+)(f?))))*"
+"[ILWYhsx]*"
+"(([Uy]*)|[sv])|([NSc]*)"
+"((c*)|([JUfhy]?))+"
+"(((q*)([So]*))(((g[jq])(j?))+))*"
+"((b+)|(((T+)([fw]T))?))*"
+"((([DS]?)|([Th]|u))(Q*))*"
+"[FKLX]|((([fw](L?))(([gq]*)|(O?)))?)"
+"((([HZ]+)u)*)|[APWijn]"
+"(e*)|(((v?)|((J+)(Hb)))?)"
+"(e|((w+)f))*"
+"[BEHKPQVdelnqy]"
+"((((B|N)(s*))|[Rr])(((g?)|([rv]+))+))+"
+"(((s*)|(K*))([AP]G))*"
+"[CELTp]"
+"(([Fq]?)|([Al]+))*"
+"((((r?)|(y[jx]))|([mp]*))+)|((B(S*))*)"
+"((([Eq]+)|(Y[ds]))|(x|(i|[Ku])))[IJNrvy]"
+"((([NO]*)[Ix])+)([Jenq]+)"
+"(((([HP]*)(j|y))*)[Ylqvy])*"
+"[PTv]+"
+"[AINSZhpx]|([EOYZ]*)"
+"([ABCFQv]*)((([Zx]|h)+)|([ej]*))"
+"((([pr]*)|(([Dq]|p)|(H?)))?)([NRUXmoq]*)"
+"(([er]*)|([mx]*))(((nV)([am]?))+)"
+"[BHPRlpu]"
+"(((([Ah]|[tx])|(e|[uy]))?)((([fl]+)([Vz]|v))*))*"
+"[AGdm]"
+"(((K*)^(O*)$)|(B?))*"
+"((([Ks]|[Ka])*)|([FSTab]?))?"
+"(([kw]+)[ei])(([Hy]*)(([Mc]*)|(G|f)))"
+"((((e*)|(Zf))|(R|[nq]))((([Jz]v)([Rj]+))+))*"
+"(((a?)|(e?))(([Uc]*)(S+)))*"
+"((((E+)([MZ]?))+)|(((s|[Az])|z)*))?"
+"((((i[MO])*)|((LH)*))|(((BA)|([AI]+))|[Ug]))*"
+"[EGHILcho]*"
+"(((Z[vw])?)((z|g)+))(((H|U)([iv]Q))|([qw]?))"
+"(([ehmr]|((L[Uw])*))+)((a+)I)"
+"[EKNSWYagj](((v|[TX])|([Uk]+))*)"
+"(((R[Mo])|(O*))|([Fm]|([qw]*)))((m*)|((S|[Ki])?))"
+"((((kP)|c)?)((([do]+)|([Gi]?))*))*"
+"((^(B|W)$|([Ww]+))([no]*))|((([iv]?)|(M*))|((x|L)?))"
+"[AEGPRSbcfhsy]"
+"[Wbcf]|((([MO]?)|([NT]|m))(([Oo]?)([Wg]*)))"
+"(((YZ)*)[PQVei])*"
+"[GJKYt][AEGWdegmnt]"
+"^[CDEGJKNUVYZagkv]$"
+"([DPWbx]*)|(((q|B)|(P|u))((M[Bq])*))"
+"[FHIJRTVYZdiorsuvz]*"
+"([MWoqvz]*)|^(l*)"
+"(((I|[Rx])*)((X[Mf])([Xa]L)))([Ha]|([HY]*))"
+"(((l|[Sd])*)((([Ix]+)|([XY]?))(Z*)))+"
--- LVM2/unit-tests/regex/TESTS	2010/07/20 15:21:33	1.1
+++ LVM2/unit-tests/regex/TESTS	2010/07/21 11:52:46	1.2
@@ -1 +1,2 @@
-dfa matching:$TEST_TOOL ./matcher_t dev_patterns < devices.list > matcher_t.output && diff -u matcher_t.expected matcher_t.output
\ No newline at end of file
+dfa matching:$TEST_TOOL ./matcher_t dev_patterns < devices.list > matcher_t.output && diff -u matcher_t.expected matcher_t.output
+dfa matching:$TEST_TOOL ./matcher_t random_regexes < /dev/null > matcher_t.output && diff -u matcher_t.expected2 matcher_t.output
\ No newline at end of file


