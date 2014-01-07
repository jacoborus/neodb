
var loop, loopArray;

// Very custom async series function
loop = function (fns, data, callback) {

	var iterate, len, cur,
		data = data;

	len = fns.length;
	// pointer
	cur = 0;
	
	iterate = function (err) {
		if (err) {
			return callback( err );
		} else {
			if (cur === len-1) {
				callback( null, data );
			} else {
				cur++;
				fns[cur]( data, iterate );
			}
		}
	}
	fns[cur]( data, iterate );
};

// Very custom async each series function
eachEach = function ( fns, arr, callback) {

	var iterate, len, cur,
		arr = arr;

	len = arr.length;
	// pointer
	cur = 0;
	
	iterate = function (err) {
		if (err) {
			return callback( err );
		} else {
			if (cur === len-1) {
				return callback( null, arr );
			} else {
				cur++;
				series( fns, arr[cur], iterate );
			}
		}
	}
	loop( fns, arr[cur], iterate );
};

// Very custom async series function
each = function (fn, arr, callback) {

	var iterate, len, cur,
		data = data;

	len = arr.length;
	// pointer
	cur = 0;
	
	iterate = function (err) {
		if (err) {
			return callback( err );
		} else {
			if (cur === len-1) {
				callback( null, arr );
			} else {
				cur++;
				fn( arr[cur], iterate );
			}
		}
	}
	fn( arr[0], iterate );
};



module.exports = {
	loop: loop,
	each: each,
	eachEach: eachEach
};