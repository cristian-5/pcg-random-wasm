(module ;; compile with --enable-memory64

	;; ==== PCG PRNG ===========================================

	(global $pcg32_state (mut i64) (i64.const 0)) ;; state for the PRNG
	(global $pcg32_increment (mut i64) (i64.const 0)) ;; increment for the seed

	(func $pcg32_srandom (export "pcg32_srandom")
	(param $initstate i64) (param $initseq i64)
		(global.set $pcg32_state (i64.const 0)) ;; state = 0
		(global.set $pcg32_increment (i64.or
			(i64.shl (local.get $initseq) (i64.const 1))
			(i64.const 1)
		)) ;; inc = (initseq << 1) | 1
		(drop (call $pcg32_next)) ;; discard next()
		(global.set $pcg32_state (local.get $initstate)) ;; state = initstate
		(drop (call $pcg32_next)) ;; discard next()
	)

	(func $pcg32_next (export "pcg32_next") (result i32)
		(local $oldstate i64)
		(local $xorshifted i32)
		(local $rot i32)
		(local.set $oldstate (global.get $pcg32_state)) ;; oldstate = state
		(global.set $pcg32_state (i64.add
			(i64.mul (local.get $oldstate) (i64.const 0x5851F42D4C957F2D))
			(global.get $pcg32_increment)
		)) ;; state = oldstate * 0x5851F42D4C957F2D + inc
		(local.set $xorshifted (i32.wrap_i64 (i64.shr_u
			(i64.xor
				(i64.shr_u (local.get $oldstate) (i64.const 18))
				(local.get $oldstate)
			)
			(i64.const 27)
		))) ;; xorshifted = ((oldstate >> 18) ^ oldstate) >> 27
		(local.set $rot (i32.wrap_i64
			(i64.shr_u (local.get $oldstate) (i64.const 59))
		)) ;; rot = oldstate >> 59
		;; (xorshifted >> rot) | (xorshifted << ((-rot) & 31))
		(i32.rotr (local.get $xorshifted) (local.get $rot))
	)

	(func $pcg32_next_bounded (export "pcg32_next_bounded")
	(param $bound i32) (result i32)
		(local $threshold i32)
		(local $r i32)
		(if (i32.eqz (local.get $bound)) (then
			(return (i32.const 0))
		)) ;; if (bound == 0) return 0
		(local.set $threshold (i32.rem_u
			(i32.sub (i32.const 0) (local.get $bound))
			(local.get $bound)
		)) ;; threshold = - bound % bound
		(loop $continue (block $break ;; while (true):
			(local.set $r (call $pcg32_next)) ;; r = next()
			(if (i32.ge_u (local.get $r) (local.get $threshold)) (then
				(return (i32.rem_u (local.get $r) (local.get $bound)))
			)) ;; if (r >= threshold) return r % bound
			(br $continue)
		))
		(i32.const 0) ;; safenet return 0
	)

	(func $pcg32_random_biased (export "pcg32_random_biased")
	(param $min i32) (param $max i32) (result i32)
		(local $range i32)
		(local $next  i32)
		(if (i32.gt_s (local.get $min) (local.get $max)) (then
			(local.set $next (local.get $min))
			(local.set $min (local.get $max))
			(local.set $max (local.get $next))
		)) ;; if min > max, swap them
		(local.set $range (i32.add
			(i32.sub (local.get $max) (local.get $min))
			(i32.const 1)
		)) ;; range = max - min + 1
		(local.set $next (i32.add (i32.rem_u
			(call $pcg32_next)
			(local.get $range)
		) (local.get $min))) ;; (next() % (max - min + 1)) + min
		(local.get $next) ;; return $next
	)
	
	(func $pcg32_random_unbiased (export "pcg32_random_unbiased")
	(param $min i32) (param $max i32) (result i32)
		(local $range i32)
		(local $next  i32)
		(if (i32.gt_s (local.get $min) (local.get $max)) (then
			(local.set $next (local.get $min))
			(local.set $min (local.get $max))
			(local.set $max (local.get $next))
		)) ;; if min > max, swap them
		(local.set $range (i32.add
			(i32.sub (local.get $max) (local.get $min))
			(i32.const 1)
		)) ;; range = max - min + 1
		(local.set $next (
			call $pcg32_next_bounded (local.get $range)
		)) ;; next = next_bounded(range)
		(i32.add (local.get $next) (local.get $min)) ;; return next + min
	)

)