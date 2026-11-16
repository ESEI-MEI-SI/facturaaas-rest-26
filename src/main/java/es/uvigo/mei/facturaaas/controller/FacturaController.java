package es.uvigo.mei.facturaaas.controller;

import es.uvigo.mei.facturaaas.dto.FacturaDTO;
import es.uvigo.mei.facturaaas.service.FacturaService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/facturas")
public class FacturaController {
    
    @Autowired
    private FacturaService facturaService;
    
    @GetMapping
    public ResponseEntity<List<FacturaDTO>> listar(
            @RequestParam(required = false) Long usuarioId,
            @RequestParam(required = false) Long clienteId) {
        if (usuarioId != null && clienteId != null) {
            return ResponseEntity.ok(facturaService.obtenerPorUsuarioYCliente(usuarioId, clienteId));
        } else if (usuarioId != null) {
            return ResponseEntity.ok(facturaService.obtenerPorUsuario(usuarioId));
        }
        return ResponseEntity.badRequest().build();
    }
    
    @GetMapping("/{id}")
    public ResponseEntity<FacturaDTO> obtenerPorId(@PathVariable Long id) {
        return ResponseEntity.ok(facturaService.obtenerPorId(id));
    }
    
    @PostMapping
    public ResponseEntity<FacturaDTO> crear(@Valid @RequestBody FacturaDTO dto) {
        FacturaDTO nueva = facturaService.crear(dto);
        return ResponseEntity.status(HttpStatus.CREATED).body(nueva);
    }
    
    @PutMapping("/{id}")
    public ResponseEntity<FacturaDTO> actualizar(
            @PathVariable Long id,
            @Valid @RequestBody FacturaDTO dto) {
        return ResponseEntity.ok(facturaService.actualizar(id, dto));
    }
    
    @PostMapping("/{id}/generar-pagos")
    public ResponseEntity<Void> generarPagos(@PathVariable Long id) {
        facturaService.generarPagos(id);
        return ResponseEntity.ok().build();
    }
}
