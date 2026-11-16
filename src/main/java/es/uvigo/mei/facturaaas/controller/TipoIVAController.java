package es.uvigo.mei.facturaaas.controller;

import es.uvigo.mei.facturaaas.dto.TipoIVADTO;
import es.uvigo.mei.facturaaas.service.TipoIVAService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/tipos-iva")
public class TipoIVAController {
    
    @Autowired
    private TipoIVAService tipoIVAService;
    
    @GetMapping
    public ResponseEntity<List<TipoIVADTO>> obtenerTodos() {
        return ResponseEntity.ok(tipoIVAService.obtenerTodos());
    }
    
    @GetMapping("/activos")
    public ResponseEntity<List<TipoIVADTO>> obtenerActivos() {
        return ResponseEntity.ok(tipoIVAService.obtenerActivos());
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<TipoIVADTO> obtenerPorId(@PathVariable Long id) {
        return ResponseEntity.ok(tipoIVAService.obtenerPorId(id));
    }
    
    @PostMapping
    public ResponseEntity<TipoIVADTO> crear(@Valid @RequestBody TipoIVADTO dto) {
        TipoIVADTO nuevo = tipoIVAService.crear(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(nuevo);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<TipoIVADTO> actualizar(
            @PathVariable Long id,
            @Valid @RequestBody TipoIVADTO dto) {
        return ResponseEntity.ok(tipoIVAService.actualizar(id, dto));
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        tipoIVAService.eliminarLogicamente(id);
        return ResponseEntity.noContent().build();
    }
}
