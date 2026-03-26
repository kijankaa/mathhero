# scripts/components/particles_correct.gd
# Efekt burst cząsteczek przy poprawnej odpowiedzi.
extends CPUParticles2D

func emit_burst() -> void:
	restart()
	emitting = true
