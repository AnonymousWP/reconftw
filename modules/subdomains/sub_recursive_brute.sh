#!/usr/bin/env bash

if { [ ! -f "$called_fn_dir/.${FUNCNAME[0]}" ] || [ "$DIFF" = true ]; } && [ "$SUB_RECURSIVE_BRUTE" = true ] && [ -s "subdomains/subdomains.txt" ]; then
	start_subfunc ${FUNCNAME[0]} "Running : Subdomains recursive search active"
	if [[ $(cat subdomains/subdomains.txt | wc -l) -le $DEEP_LIMIT ]] ; then
		[ ! -s ".tmp/subdomains_recurs_top.txt" ] && dsieve -if subdomains/subdomains.txt -f 3 -top $DEEP_RECURSIVE_PASSIVE > .tmp/subdomains_recurs_top.txt
		ripgen -d .tmp/subdomains_recurs_top.txt -w $subs_wordlist > .tmp/brute_recursive_wordlist.txt
		if [ ! "$AXIOM" = true ]; then
			resolvers_update_quick_local
			[ -s ".tmp/brute_recursive_wordlist.txt" ] && puredns resolve .tmp/brute_recursive_wordlist.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT  --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -w .tmp/brute_recursive_result.txt 2>>"$LOGFILE" &>/dev/null
		else
			resolvers_update_quick_axiom
			[ -s ".tmp/brute_recursive_wordlist.txt" ] && axiom-scan .tmp/brute_recursive_wordlist.txt -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/brute_recursive_result.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
		fi
		[ -s ".tmp/brute_recursive_result.txt" ] && cat .tmp/brute_recursive_result.txt | anew -q .tmp/brute_recursive.txt
		if [ "$PERMUTATIONS_OPTION" = "gotator" ] ; then
			[ -s ".tmp/brute_recursive.txt" ] && gotator -sub .tmp/brute_recursive.txt -perm $tools/permutations_list.txt $GOTATOR_FLAGS -silent 2>>"$LOGFILE" | head -c $PERMUTATIONS_LIMIT > .tmp/gotator1_recursive.txt
		else
			[ -s ".tmp/brute_recursive.txt" ] && ripgen -d .tmp/brute_recursive.txt -w $tools/permutations_list.txt 2>>"$LOGFILE" | head -c $PERMUTATIONS_LIMIT > .tmp/gotator1_recursive.txt
		fi			
		if [ ! "$AXIOM" = true ]; then
			[ -s ".tmp/gotator1_recursive.txt" ] && puredns resolve .tmp/gotator1_recursive.txt -w .tmp/permute1_recursive.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT  --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT 2>>"$LOGFILE" &>/dev/null
		else
			[ -s ".tmp/gotator1_recursive.txt" ] && axiom-scan .tmp/gotator1_recursive.txt -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/permute1_recursive.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
		fi
		if [ "$PERMUTATIONS_OPTION" = "gotator" ] ; then
			[ -s ".tmp/permute1_recursive.txt" ] && gotator -sub .tmp/permute1_recursive.txt -perm $tools/permutations_list.txt $GOTATOR_FLAGS -silent 2>>"$LOGFILE" | head -c $PERMUTATIONS_LIMIT > .tmp/gotator2_recursive.txt
		else
			[ -s ".tmp/permute1_recursive.txt" ] && ripgen -d .tmp/permute1_recursive.txt -w $tools/permutations_list.txt 2>>"$LOGFILE" | head -c $PERMUTATIONS_LIMIT > .tmp/gotator2_recursive.txt
		fi			
		if [ ! "$AXIOM" = true ]; then
		[ -s ".tmp/gotator2_recursive.txt" ] && puredns resolve .tmp/gotator2_recursive.txt -w .tmp/permute2_recursive.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT  --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT 2>>"$LOGFILE" &>/dev/null
		else
			[ -s ".tmp/gotator2_recursive.txt" ] && axiom-scan .tmp/gotator2_recursive.txt -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/permute2_recursive.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
		fi
		cat .tmp/permute1_recursive.txt .tmp/permute2_recursive.txt 2>>"$LOGFILE" | anew -q .tmp/permute_recursive.txt
	else
		end_subfunc "skipped in this mode or defined in reconftw.cfg" ${FUNCNAME[0]}
	fi
	if [ "$INSCOPE" = true ]; then
		check_inscope .tmp/permute_recursive.txt 2>>"$LOGFILE" &>/dev/null
		check_inscope .tmp/brute_recursive.txt 2>>"$LOGFILE" &>/dev/null
	fi
	# Last validation
	cat .tmp/permute_recursive.txt .tmp/brute_recursive.txt 2>>"$LOGFILE" | anew -q .tmp/brute_perm_recursive.txt
	if [ ! "$AXIOM" = true ]; then
		[ -s ".tmp/brute_recursive.txt" ] && puredns resolve .tmp/brute_perm_recursive.txt -w .tmp/brute_perm_recursive_final.txt -r $resolvers --resolvers-trusted $resolvers_trusted -l $PUREDNS_PUBLIC_LIMIT --rate-limit-trusted $PUREDNS_TRUSTED_LIMIT --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT 2>>"$LOGFILE" &>/dev/null
	else
		[ -s ".tmp/brute_recursive.txt" ] && axiom-scan .tmp/brute_perm_recursive.txt -m puredns-resolve -r /home/op/lists/resolvers.txt --resolvers-trusted /home/op/lists/resolvers_trusted.txt --wildcard-tests $PUREDNS_WILDCARDTEST_LIMIT --wildcard-batch $PUREDNS_WILDCARDBATCH_LIMIT -o .tmp/brute_perm_recursive_final.txt $AXIOM_EXTRA_ARGS 2>>"$LOGFILE" &>/dev/null
	fi
	NUMOFLINES=$(cat .tmp/brute_perm_recursive_final.txt 2>>"$LOGFILE" | grep "\.$domain$\|^$domain$" | sed '/^$/d' | anew subdomains/subdomains.txt | wc -l)
	end_subfunc "${NUMOFLINES} new subs (recursive)" ${FUNCNAME[0]}
else
	if [ "$SUB_RECURSIVE_BRUTE" = false ]; then
		printf "\n${yellow} ${FUNCNAME[0]} skipped in this mode or defined in reconftw.cfg ${reset}\n"
	else
		printf "${yellow} ${FUNCNAME[0]} is already processed, to force executing ${FUNCNAME[0]} delete\n    $called_fn_dir/.${FUNCNAME[0]} ${reset}\n\n"
	fi
fi