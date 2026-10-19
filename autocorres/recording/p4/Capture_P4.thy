theory Capture_P4
imports "AutoCorres2.AutoCorres"
begin
ML_file "../record_states.ML"
ML \<open>Lab_Record.record_file "/work/autocorres/p4/P4" "/work/results/rework/autocorres-p4-states.xml"\<close>
end
