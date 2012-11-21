$(function(){
	$('.selectAll').click(function(){
		var checkStatus = $(this)[0].checked;
		$('.subSelect', $(this).closest('table')).each(function(i){
			this.checked = checkStatus;
		});
	});
	$('.subSelect').click(function(){
		var $selectAll = $('.selectAll', $(this).closest('table'));
		var checkStatus = $(this)[0].checked;
		var f = false;
		if (!checkStatus) {
			$selectAll[0].checked = false;
		} else {
			$('.subSelect', $(this).closest('table')).each(function(i){
				if (!this.checked) {
					f = true;
				}
			});
			if (f == false) {
				$selectAll[0].checked = true;
			}
		}
	});
});
